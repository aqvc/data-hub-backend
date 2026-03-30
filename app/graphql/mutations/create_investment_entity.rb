module Mutations
  class CreateInvestmentEntity < Mutations::BaseMutation
    argument :investor_id, ID, required: false
    argument :investment_vehicle_id, ID, required: false

    field :id, ID, null: false

    def resolve(investor_id: nil, investment_vehicle_id: nil)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      vehicle_id = investment_vehicle_id
      if vehicle_id.blank?
        investor = Investor.find_by(id: investor_id)
        raise_not_found("Investors.NotFound", investor_id, "investor") if investor.nil?

        vehicle_id = investor.investment_vehicles.order(created_at_utc: :desc).pick(:id)
      end

      vehicle = InvestmentVehicle.find_by(id: vehicle_id)
      raise_not_found("InvestmentVehicles.NotFound", vehicle_id, "investment vehicle") if vehicle.nil?

      entity = InvestmentEntity.new(
        investment_vehicle_id: vehicle.id,
        created_by_id: current_user_id,
        created_at_utc: Time.now.utc
      )

      if entity.save
        { id: entity.id }
      else
        raise_execution_error(code: "InvestmentEntities.CreateFailed", detail: entity.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end
    end
  end
end
