module Mutations
  class SendInvitation < Mutations::BaseMutation
    VALID_ROLES = %w[admin account_manager data_manager member].freeze

    argument :email, String, required: true
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :role_name, String, required: true

    field :id, ID, null: false
    field :email, String, null: false

    def resolve(email:, first_name:, last_name:, role_name:)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ADMIN_ROLES)

      normalized_email = email.to_s.strip.downcase
      validate_email!(normalized_email)
      validate_role!(role_name)

      existing_user = User.find_by(normalized_email: normalized_email.upcase)
      if existing_user&.invitation_accepted_at.present? || (existing_user && !existing_user.created_by_invite?)
        raise_execution_error(code: "Invitations.EmailTaken", detail: "A user with this email already exists.", status: 409, type: "https://tools.ietf.org/html/rfc7231#section-6.5.8")
      end

      user = nil
      ActiveRecord::Base.transaction do
        user = if existing_user
                 existing_user.update!(first_name: first_name, last_name: last_name)
                 existing_user.invite!(current_user)
                 existing_user
               else
                 User.invite!(
                   {
                     email: normalized_email,
                     first_name: first_name,
                     last_name: last_name,
                     user_name: normalized_email,
                     email_confirmed: false,
                     security_stamp: SecureRandom.uuid,
                     concurrency_stamp: SecureRandom.uuid,
                     access_failed_count: 0,
                     phone_number_confirmed: false,
                     two_factor_enabled: false,
                     lockout_enabled: true,
                     created_by_id: current_user_id
                   },
                   current_user
                 )
               end

        user.add_role(role_name.to_sym)
      end

      { id: user.id, email: user.email }
    rescue ActiveRecord::RecordInvalid => e
      raise_execution_error(code: "Invitations.Failed", detail: e.record.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    rescue GraphQL::ExecutionError
      raise
    rescue StandardError => e
      ErrorTracker.error("SendInvitation failed: #{e.class} - #{e.message}")
      raise_execution_error(code: "Invitations.Failed", detail: "Failed to send invitation.", status: 500, type: "https://tools.ietf.org/html/rfc7231#section-6.6.1")
    end

    private

    def validate_email!(email)
      return if email.match?(URI::MailTo::EMAIL_REGEXP)

      raise_execution_error(code: "Invitations.InvalidEmail", detail: "Email must be a valid email address.", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    end

    def validate_role!(role_name)
      return if VALID_ROLES.include?(role_name)

      raise_execution_error(code: "Invitations.InvalidRole", detail: "Role must be one of: #{VALID_ROLES.join(', ')}", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    end
  end
end
