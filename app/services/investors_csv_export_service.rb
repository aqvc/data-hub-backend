require "csv"

class InvestorsCsvExportService
  def initialize(params:, mode:)
    @params = params
    @mode = mode
  end

  def call
    investors = scope_for_mode
    columns = resolved_columns

    CSV.generate(headers: true) do |csv|
      csv << columns
      investors.to_a.each do |investor|
        csv << columns.map { |col| value_for(investor, col) }
      end
    end
  end

  private

  def scope_for_mode
    case @mode
    when :filters
      InvestorsSearchService.new(@params, base_scope: export_includes).filtered_and_sorted_scope
    when :ids
      selected_ids = Array(@params[:selectedIds]).map(&:to_s).reject(&:blank?)
      export_includes.where(id: selected_ids)
    else
      raise ArgumentError, "Unknown export mode: #{@mode.inspect}"
    end
  end

  def export_includes
    Investor.includes(
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

  def resolved_columns
    columns = Array(@params[:columns]).map(&:to_s).reject { |c| c.blank? || c == "select" || c == "actions" }
    columns.empty? ? InvestorsSerializer::DEFAULT_EXPORT_COLUMNS.dup : columns
  end

  def value_for(investor, column)
    strategies = InvestorsSerializer.strategies_for(investor)
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
end
