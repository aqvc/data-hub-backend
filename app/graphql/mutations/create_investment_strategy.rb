module Mutations
  class CreateInvestmentStrategy < Mutations::BaseMutation
    argument :investor_id, ID, required: true
    argument :name, String, required: false

    field :id, ID, null: false

    def resolve(investor_id:, name: nil)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      investor = Investor.find_by(id: investor_id)
      raise_not_found("Investors.NotFound", investor_id, "investor") if investor.nil?

      strategy = InvestmentStrategy.new(
        investor_id: investor.id,
        name: name.presence || "",
        investor_type_focus: [],
        sector_investment_focus: [],
        maturity_focus: [],
        stage_focus: [],
        asset_class_focus: [],
        strategy_focus: [],
        created_by_id: current_user_id,
        created_at_utc: Time.now.utc
      )

      if strategy.save
        { id: strategy.id }
      else
        raise_execution_error(code: "InvestmentStrategies.CreateFailed", detail: strategy.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end
    end
  end
end
