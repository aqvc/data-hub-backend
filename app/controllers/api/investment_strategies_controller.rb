module Api
  class InvestmentStrategiesController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES

    before_action do
      authenticate_with_roles!(*ALL_ROLES)
    end

    def show
      strategy = InvestmentStrategy
                 .includes(:investment_strategy_region_focuses, :investment_strategy_country_focuses)
                 .find_by(id: params[:id])
      return render_not_found("InvestmentStrategies.NotFound", params[:id]) if strategy.nil?

      payload = serialize_record(strategy)
      payload["regionInvestmentFocus"] = strategy.investment_strategy_region_focuses.includes(:region).map do |focus|
        next nil if focus.region.nil?

        { "id" => focus.region.id, "name" => focus.region.name }
      end.compact
      payload["countryInvestmentFocus"] = strategy.investment_strategy_country_focuses.includes(:country).map do |focus|
        next nil if focus.country.nil?

        { "id" => focus.country.id, "name" => focus.country.name }
      end.compact
      render json: payload, status: :ok
    end

    def create
      investor = Investor.find_by(id: params[:investorId])
      return render_not_found("Investors.NotFound", params[:investorId]) if investor.nil?

      strategy = InvestmentStrategy.new(
        investor_id: investor.id,
        name: params[:name].presence || "",
        created_by_id: current_user_id,
        created_at_utc: Time.now.utc
      )

      if strategy.save
        render json: { id: strategy.id }, status: :ok
      else
        render_problem(
          code: "InvestmentStrategies.CreateFailed",
          detail: strategy.errors.full_messages.join(", "),
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end
    end

    def update
      strategy = InvestmentStrategy.find_by(id: params[:id])
      return render_not_found("InvestmentStrategies.NotFound", params[:id]) if strategy.nil?

      attrs = extract_model_attributes(:investmentStrategy)
      region_ids = attrs.delete("region_investment_focus")
      country_ids = attrs.delete("country_investment_focus")

      assign_filtered_attributes(strategy, attrs)
      strategy.updated_by_id = current_user_id if strategy.respond_to?(:updated_by_id=)
      strategy.updated_at_utc = Time.now.utc if strategy.respond_to?(:updated_at_utc=)

      ActiveRecord::Base.transaction do
        strategy.save!
        replace_region_focuses(strategy, region_ids) if region_ids.is_a?(Array)
        replace_country_focuses(strategy, country_ids) if country_ids.is_a?(Array)
        ProofLedgerPersistenceService.new(
          proof_points: params[:proofPoints],
          current_user_id: current_user_id,
          fallback_relation: { "investment_strategy_id" => strategy.id }
        ).call
      end

      head :ok
    rescue ActiveRecord::RecordInvalid => e
      render_problem(
        code: "InvestmentStrategies.UpdateFailed",
        detail: e.record.errors.full_messages.join(", "),
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 400
      )
    end

    private

    def replace_region_focuses(strategy, region_ids)
      strategy.investment_strategy_region_focuses.delete_all
      region_ids.map(&:presence).compact.each do |region_id|
        InvestmentStrategyRegionFocus.create!(
          investment_strategy_id: strategy.id,
          region_id: region_id
        )
      end
    end

    def replace_country_focuses(strategy, country_ids)
      strategy.investment_strategy_country_focuses.delete_all
      country_ids.map(&:presence).compact.each do |country_id|
        InvestmentStrategyCountryFocus.create!(
          investment_strategy_id: strategy.id,
          country_id: country_id
        )
      end
    end

    def current_user_id
      current_user_claims[JwtTokenService::NAME_ID_CLAIM]
    end

    def render_not_found(code, id)
      render_problem(
        code: code,
        detail: "The resource with the Id = '#{id}' was not found",
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
        status: 404
      )
    end
  end
end
