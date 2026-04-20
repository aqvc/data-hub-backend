module Api
  class InvestorsController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES
    EXPORT_RECORD_LIMIT = 2_000

    before_action only: [:search, :create, :show, :update, :qualify, :export_by_filters, :export_by_ids] do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def search
      page = [params[:page].to_i, 1].max
      limit = params[:limit].to_i.positive? ? params[:limit].to_i : 10
      limit = [limit, 100].min

      investors = Investor
                  .includes(
                    location: { country: :region },
                    investment_vehicles: {
                      investment_vehicle_investment_strategies: {
                        investment_strategy: [
                          { investment_strategy_region_focuses: :region },
                          { investment_strategy_country_focuses: :country }
                        ]
                      }
                    }
                  )

      name_filter = params.dig(:columnFilter, :name).to_s.strip
      if name_filter.present?
        term = "%#{name_filter.downcase}%"
        investors = investors
                    .left_outer_joins(:investment_vehicles)
                    .left_outer_joins(investment_vehicles: :investment_vehicle_investment_strategies)
                    .left_outer_joins(
                      investment_vehicles: {
                        investment_vehicle_investment_strategies: :investment_strategy
                      }
                    )
                    .where(
                      "LOWER(public.investors.name) LIKE :term OR LOWER(public.investment_vehicles.name) LIKE :term OR LOWER(public.investment_strategies.name) LIKE :term",
                      term: term
                    )
                    .distinct
      end

      sort_field = params.dig(:sort, 0, :field).to_s
      sort_direction = params.dig(:sort, 0, :direction).to_s.downcase == "desc" ? "DESC" : "ASC"
      order_sql = case sort_field
                  when "updatedAtUtc" then "public.investors.updated_at_utc #{sort_direction} NULLS LAST"
                  else "public.investors.name #{sort_direction}, public.investors.id ASC"
                  end
      investors = investors.order(Arel.sql(order_sql))

      total = investors.count
      data = investors.offset((page - 1) * limit).limit(limit).to_a.map { |investor| serialize_investor(investor) }
      total_pages = (total.to_f / limit).ceil

      render json: {
        total: total,
        page: page,
        totalPages: total_pages,
        limit: limit,
        hasNext: page < total_pages,
        hasPrev: page > 1,
        data: data
      }, status: :ok
    end

    def export_by_filters
      investors = filtered_and_sorted_scope
      return render_export_limit_exceeded if investor_count(investors) > EXPORT_RECORD_LIMIT

      csv_data = build_csv(investors, params[:columns])
      send_data csv_data, filename: "Investors.csv", type: "text/csv"
    end

    def export_by_ids
      selected_ids = Array(params[:selectedIds]).map(&:to_s).reject(&:blank?).uniq
      return render_export_limit_exceeded if selected_ids.size > EXPORT_RECORD_LIMIT

      investors = export_base_scope.where(id: selected_ids)
      csv_data = build_csv(investors, params[:columns])
      send_data csv_data, filename: "Investors.csv", type: "text/csv"
    end

    def create
      user_id = current_user_id
      if user_id.blank?
        return render_problem(
          code: "Users.Unauthorized",
          detail: "You are not authorized to perform this action.",
          type: "https://tools.ietf.org/html/rfc7231#section-6.6.1",
          status: 500
        )
      end

      investor = Investor.new(
        name: "",
        created_by_id: user_id,
        created_at_utc: Time.now.utc,
        qualified: false
      )

      if investor.save
        render json: { id: investor.id }, status: :ok
      else
        render_problem(
          code: "Investors.CreateFailed",
          detail: investor.errors.full_messages.join(", "),
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end
    end

    def show
      investor = Investor.includes(
        :location,
        :investment_vehicles,
        :investment_strategies
      ).find_by(id: params[:id])

      if investor.nil?
        return render_problem(
          code: "Investors.NotFound",
          detail: "The investor with the Id = '#{params[:id]}' was not found",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
          status: 404
        )
      end

      render json: serialize_investor_detail(investor), status: :ok
    end

    def update
      investor = Investor.find_by(id: params[:id])
      if investor.nil?
        return render_problem(
          code: "Investors.NotFound",
          detail: "The investor with the Id = '#{params[:id]}' was not found",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
          status: 404
        )
      end

      attrs = extract_model_attributes(:investor)
      assign_filtered_attributes(investor, attrs)
      investor.updated_by_id = current_user_id if investor.respond_to?(:updated_by_id=)
      investor.updated_at_utc = Time.now.utc if investor.respond_to?(:updated_at_utc=)
      ActiveRecord::Base.transaction do
        investor.save!
        ProofLedgerPersistenceService.persist_from_payload!(
          proof_points: params[:proofPoints],
          current_user_id: current_user_id,
          fallback_relation: { "investor_id" => investor.id }
        )
      end
      head :ok
    rescue ActiveRecord::RecordInvalid => e
      render_problem(
        code: "Investors.UpdateFailed",
        detail: e.record.errors.full_messages.join(", "),
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 400
      )
    end

    def qualify
      investor = Investor.find_by(id: params[:id])
      if investor.nil?
        return render_problem(
          code: "Investors.NotFound",
          detail: "The investor with the Id = '#{params[:id]}' was not found",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
          status: 404
        )
      end

      investor.qualified = ActiveModel::Type::Boolean.new.cast(params[:qualified])
      investor.updated_by_id = current_user_id if investor.respond_to?(:updated_by_id=)
      investor.updated_at_utc = Time.now.utc if investor.respond_to?(:updated_at_utc=)

      if investor.save
        head :ok
      else
        render_problem(
          code: "Investors.QualifyFailed",
          detail: investor.errors.full_messages.join(", "),
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end
    end

    private

    def current_user_id
      current_user_claims[JwtTokenService::NAME_ID_CLAIM]
    end

    def serialize_investor(investor)
      strategies = investor.investment_vehicles
                           .flat_map(&:investment_vehicle_investment_strategies)
                           .map(&:investment_strategy)
                           .compact
                           .uniq(&:id)

      {
        id: investor.id,
        name: investor.name,
        websiteUrl: investor.website_url,
        type: investor.type,
        updatedAtUtc: investor.updated_at_utc,
        qualified: investor.qualified,
        offices: investor.offices,
        location: serialize_location(investor.location),
        investmentVehicles: investor.investment_vehicles.map do |vehicle|
          {
            id: vehicle.id,
            name: vehicle.name
          }
        end,
        investmentStrategies: strategies.map { |s| serialize_strategy(s) }
      }
    end

    def serialize_location(location)
      return nil if location.nil?

      {
        id: location.id,
        city: location.city,
        country: {
          id: location.country&.id,
          name: location.country&.name,
          region: {
            id: location.country&.region&.id,
            name: location.country&.region&.name
          }
        }
      }
    end

    def serialize_strategy(strategy)
      {
        id: strategy.id,
        name: strategy.name,
        assetClassFocus: strategy.asset_class_focus || [],
        sectorInvestmentFocus: strategy.sector_investment_focus || [],
        maturityFocus: strategy.maturity_focus || [],
        stageFocus: strategy.stage_focus || [],
        investorTypeFocus: strategy.investor_type_focus || [],
        regionInvestmentFocus: strategy.investment_strategy_region_focuses.map { |rf| rf.region&.name }.compact,
        countryInvestmentFocus: strategy.investment_strategy_country_focuses.map { |cf| cf.country&.name }.compact
      }
    end

    def filtered_and_sorted_scope
      investors = export_base_scope
      name_filter = params.dig(:columnFilter, :name).to_s.strip
      if name_filter.present?
        term = "%#{name_filter.downcase}%"
        investors = investors
                    .left_outer_joins(:investment_vehicles)
                    .left_outer_joins(investment_vehicles: :investment_vehicle_investment_strategies)
                    .left_outer_joins(
                      investment_vehicles: {
                        investment_vehicle_investment_strategies: :investment_strategy
                      }
                    )
                    .where(
                      "LOWER(public.investors.name) LIKE :term OR LOWER(public.investment_vehicles.name) LIKE :term OR LOWER(public.investment_strategies.name) LIKE :term",
                      term: term
                    )
                    .distinct
      end

      sort_field = params.dig(:sort, 0, :field).to_s
      sort_direction = params.dig(:sort, 0, :direction).to_s.downcase == "desc" ? "DESC" : "ASC"
      order_sql = case sort_field
                  when "updatedAtUtc" then "public.investors.updated_at_utc #{sort_direction} NULLS LAST"
                  else "public.investors.name #{sort_direction}, public.investors.id ASC"
                  end
      investors.order(Arel.sql(order_sql))
    end

    def investor_count(scope)
      scope.except(:order).reselect("public.investors.id").distinct.count
    end

    def render_export_limit_exceeded
      render_problem(
        code: "Investors.ExportLimitExceeded",
        detail: "You can export up to #{EXPORT_RECORD_LIMIT} records at a time. Please refine your filters and try again.",
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 422
      )
    end

    def export_base_scope
      Investor
        .includes(
          :investor_contacts,
          location: { country: :region },
          investment_vehicles: {
            investment_vehicle_investment_strategies: {
              investment_strategy: [
                { investment_strategy_region_focuses: :region },
                { investment_strategy_country_focuses: :country }
              ]
            }
          }
        )
    end

    def build_csv(investors, requested_columns)
      require "csv"

      columns = Array(requested_columns).map(&:to_s).reject { |c| c.blank? || c == "select" || c == "actions" }
      columns = ["name", "websiteUrl", "investorType", "headquarter", "updatedAtUtc"] if columns.empty?

      CSV.generate(headers: true) do |csv|
        csv << columns
        investors.to_a.each do |investor|
          csv << columns.map { |col| csv_value_for(investor, col) }
        end
      end
    end

    def csv_value_for(investor, column)
      strategies = investor.investment_vehicles
                           .flat_map(&:investment_vehicle_investment_strategies)
                           .map(&:investment_strategy)
                           .compact
                           .uniq(&:id)
      case column
      when "name" then investor.name
      when "websiteUrl" then investor.website_url
      when "investorType" then investor.type
      when "headquarter" then [investor.location&.city, investor.location&.country&.name, investor.location&.country&.region&.name].compact.join(", ")
      when "headquarterRegion" then investor.location&.country&.region&.name
      when "headquarterCountry" then investor.location&.country&.name
      when "headquarterCity" then investor.location&.city
      when "updatedAtUtc" then investor.updated_at_utc
      when "assetClassFocus" then strategies.flat_map { |s| Array(s.asset_class_focus) }.uniq.join(", ")
      when "sectorInvestmentFocus" then strategies.flat_map { |s| Array(s.sector_investment_focus) }.uniq.join(", ")
      when "regionInvestmentFocus" then strategies.flat_map { |s| s.investment_strategy_region_focuses.map { |rf| rf.region&.name } }.compact.uniq.join(", ")
      when "countryInvestmentFocus" then strategies.flat_map { |s| s.investment_strategy_country_focuses.map { |cf| cf.country&.name } }.compact.uniq.join(", ")
      when "maturityFocus" then strategies.flat_map { |s| Array(s.maturity_focus) }.uniq.join(", ")
      when "investorTypeFocus" then strategies.flat_map { |s| Array(s.investor_type_focus) }.uniq.join(", ")
      when "stageFocus" then strategies.flat_map { |s| Array(s.stage_focus) }.uniq.join(", ")
      when "numberOfContacts" then investor.investor_contacts.size
      when "saturation" then nil
      when "investmentVehiclesCount" then investor.investment_vehicles.size
      when "investmentVehicleNames" then investor.investment_vehicles.map(&:name).compact.join(", ")
      when "qualified" then investor.qualified
      when "organization" then investor.respond_to?(:organization_profile_id) ? investor.organization_profile_id : nil
      when "iip" then nil
      else
        attr = column.to_s.underscore
        investor.respond_to?(attr) ? investor.public_send(attr) : nil
      end
    end

    def serialize_investor_detail(investor)
      payload = serialize_record(investor)
      payload["location"] = serialize_location(investor.location)
      payload["investmentVehicles"] = investor.investment_vehicles.map { |vehicle| serialize_record(vehicle) }
      payload["investmentStrategies"] = investor.investment_strategies.map { |strategy| serialize_record(strategy) }
      payload["contactsCount"] = investor.investor_contacts.count
      payload["investmentEntitiesCount"] = InvestmentEntity
                                           .joins(:investment_vehicle)
                                           .where("\"public\".\"investment_vehicles\".\"investor_id\" = ?", investor.id)
                                           .count
      payload
    end
  end
end
