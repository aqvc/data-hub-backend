module Mutations
  class QualifyInvestor < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :qualified, Boolean, required: true

    field :success, Boolean, null: false

    def resolve(id:, qualified:)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      investor = Investor.find_by(id: id)
      raise_not_found("Investors.NotFound", id, "investor") if investor.nil?

      investor.qualified = qualified
      investor.updated_by_id = current_user_id if investor.respond_to?(:updated_by_id=)
      investor.updated_at_utc = Time.now.utc if investor.respond_to?(:updated_at_utc=)

      if investor.save
        { success: true }
      else
        raise_execution_error(code: "Investors.QualifyFailed", detail: investor.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end
    end
  end
end
