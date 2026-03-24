module Mutations
  class CreateInvestor < Mutations::BaseMutation
    field :id, ID, null: false

    def resolve
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)
      raise_execution_error(code: "Users.Unauthorized", detail: "You are not authorized to perform this action.", status: 500, type: "https://tools.ietf.org/html/rfc7231#section-6.6.1") if current_user_id.blank?

      investor = Investor.new(
        name: "",
        created_by_id: current_user_id,
        created_at_utc: Time.now.utc,
        qualified: false
      )

      if investor.save
        { id: investor.id }
      else
        raise_execution_error(code: "Investors.CreateFailed", detail: investor.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end
    end
  end
end
