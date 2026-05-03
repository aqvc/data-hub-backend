module Mutations
  class Login < Mutations::BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :authenticated, Boolean, null: false
    field :user_id, ID, null: false
    field :roles, [String], null: false

    def resolve(email:, password:)
      user = User.find_by(email: email.to_s)
      raise_execution_error(code: "Users.NotFoundByEmail", detail: "The user with the specified email was not found", status: 404, type: "https://tools.ietf.org/html/rfc7231#section-6.5.4") if user.nil?

      unless user.valid_password?(password.to_s)
        raise_execution_error(code: "Users.Unauthorized", detail: "You are not authorized to perform this action.", status: 401, type: "https://tools.ietf.org/html/rfc7231#section-6.6.1")
      end

      roles = user.role_names
      controller.reset_session
      controller.session[:current_user_id] = user.id
      controller.session[:current_user_roles] = roles

      { authenticated: true, user_id: user.id, roles: roles }
    rescue GraphQL::ExecutionError
      raise
    rescue StandardError => e
      ErrorTracker.error("Mutations::Login failed: #{e.class} - #{e.message}")
      raise_execution_error(code: "Users.AuthenticationFailed", detail: "The user authentication failed", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    end
  end
end
