module Mutations
  class AcceptInvitation < Mutations::BaseMutation
    argument :invitation_token, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true
    argument :first_name, String, required: true
    argument :last_name, String, required: true

    field :authenticated, Boolean, null: false
    field :user_id, ID, null: false
    field :roles, [String], null: false

    def resolve(invitation_token:, password:, password_confirmation:, first_name:, last_name:)
      user = User.find_by_invitation_token(invitation_token, true)

      if user.nil?
        raise_execution_error(code: "Invitations.InvalidToken", detail: "The invitation token is invalid or has expired.", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end

      if password != password_confirmation
        raise_execution_error(code: "Invitations.PasswordMismatch", detail: "Password and confirmation do not match.", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end

      user.assign_attributes(
        first_name: first_name,
        last_name: last_name,
        password: password,
        password_confirmation: password_confirmation,
        email_confirmed: true
      )
      user.accept_invitation!

      unless user.errors.empty?
        raise_execution_error(code: "Invitations.AcceptFailed", detail: user.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end

      roles = user.role_names
      controller.reset_session
      controller.session[:current_user_id] = user.id
      controller.session[:current_user_roles] = roles

      { authenticated: true, user_id: user.id, roles: roles }
    rescue GraphQL::ExecutionError
      raise
    rescue StandardError => e
      ErrorLogger.error("AcceptInvitation failed: #{e.class} - #{e.message}")
      raise_execution_error(code: "Invitations.AcceptFailed", detail: "Failed to accept invitation.", status: 500, type: "https://tools.ietf.org/html/rfc7231#section-6.6.1")
    end
  end
end
