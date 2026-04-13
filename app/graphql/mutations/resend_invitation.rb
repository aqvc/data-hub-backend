module Mutations
  class ResendInvitation < Mutations::BaseMutation
    argument :user_id, ID, required: true

    field :success, Boolean, null: false

    def resolve(user_id:)
      authorize_roles!(GraphqlSupport::AuthHelpers::ADMIN_ROLE)

      user = User.find_by(id: user_id)
      raise_not_found("Users.NotFound", user_id, "user") if user.nil?

      unless user.created_by_invite? && !user.invitation_accepted_at?
        raise_execution_error(code: "Invitations.NotPending", detail: "This user does not have a pending invitation.", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end

      user.invite!(current_user)

      { success: true }
    rescue GraphQL::ExecutionError
      raise
    rescue StandardError => e
      Rails.logger.error("ResendInvitation failed: #{e.class} - #{e.message}")
      raise_execution_error(code: "Invitations.ResendFailed", detail: "Failed to resend invitation.", status: 500, type: "https://tools.ietf.org/html/rfc7231#section-6.6.1")
    end
  end
end
