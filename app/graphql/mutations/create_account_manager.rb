module Mutations
  class CreateAccountManager < Mutations::BaseMutation
    DEFAULT_PASSWORD = "Password123!".freeze

    argument :email, String, required: true
    argument :password, String, required: false
    argument :first_name, String, required: false
    argument :last_name, String, required: false

    field :id, ID, null: false

    def resolve(email:, password: nil, first_name: nil, last_name: nil)
      authorize_roles!(GraphqlSupport::AuthHelpers::ADMIN_ROLE)

      normalized_email = email.to_s.strip
      unless normalized_email.match?(URI::MailTo::EMAIL_REGEXP)
        raise_execution_error(code: "Users.RegistrationFailed", detail: "Email must be a valid email address.", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end

      if User.exists?(normalized_email: normalized_email.upcase)
        raise_execution_error(code: "Users.EmailNotUnique", detail: "The provided email is not unique", status: 409, type: "https://tools.ietf.org/html/rfc7231#section-6.5.8")
      end

      role = Role.find_by(name: "AccountManager") || Role.find_by(normalized_name: "ACCOUNTMANAGER")
      raise_execution_error(code: "Users.RegistrationFailed", detail: "The user registration failed", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1") if role.nil?

      user_id = nil
      now = Time.now.utc

      ActiveRecord::Base.transaction do
        user = User.create!(
          email: normalized_email,
          user_name: normalized_email,
          email_confirmed: true,
          password: password.presence || DEFAULT_PASSWORD,
          password_confirmation: password.presence || DEFAULT_PASSWORD,
          security_stamp: SecureRandom.uuid,
          concurrency_stamp: SecureRandom.uuid,
          access_failed_count: 0,
          phone_number_confirmed: false,
          two_factor_enabled: false,
          lockout_enabled: true,
          created_by_id: current_user_id,
          created_at_utc: now
        )

        UserRole.create!(user_id: user.id, role_id: role.id)
        UserDetail.create!(
          id: user.id,
          first_name: first_name.to_s,
          last_name: last_name.to_s,
          created_by_id: current_user_id,
          created_at_utc: now
        )

        user_id = user.id
      end

      { id: user_id }
    rescue ActiveRecord::RecordInvalid => e
      raise_execution_error(code: "Users.RegistrationFailed", detail: e.record.errors.full_messages.join(", ").presence || "The user registration failed", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    rescue GraphQL::ExecutionError
      raise
    rescue StandardError
      raise_execution_error(code: "Users.RegistrationFailed", detail: "The user registration failed", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    end
  end
end
