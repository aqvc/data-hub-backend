module Mutations
  class DeleteInvestorContact < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(id:)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      contact = InvestorContact.find_by(id: id)
      raise_not_found("InvestorContacts.NotFound", id, "investor contact") if contact.nil?

      contact.destroy
      { success: true }
    end
  end
end
