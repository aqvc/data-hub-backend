module Mutations
  class DeleteInvestmentEntity < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(id:)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      entity = InvestmentEntity.find_by(id: id)
      raise_not_found("InvestmentEntities.NotFound", id, "investment entity") if entity.nil?

      entity.destroy
      { success: true }
    end
  end
end
