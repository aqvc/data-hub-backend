module Mutations
  class CreateInvestmentVehicle < Mutations::BaseMutation
    argument :investor_id, ID, required: true
    argument :name, String, required: false

    field :id, ID, null: false

    def resolve(investor_id:, name: nil)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      investor = Investor.find_by(id: investor_id)
      raise_not_found("Investors.NotFound", investor_id, "investor") if investor.nil?

      vehicle = InvestmentVehicle.new(
        investor_id: investor.id,
        name: name.presence || "",
        created_by_id: current_user_id,
        created_at_utc: Time.now.utc
      )

      if vehicle.save
        { id: vehicle.id }
      else
        raise_execution_error(code: "InvestmentVehicles.CreateFailed", detail: vehicle.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end
    end
  end
end
