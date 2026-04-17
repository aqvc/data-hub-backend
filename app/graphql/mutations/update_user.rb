module Mutations
  class UpdateUser < Mutations::BaseMutation
    VALID_ROLES = %w[admin account_manager data_manager member].freeze

    argument :id, ID, required: true
    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :role_name, String, required: false

    field :success, Boolean, null: false

    def resolve(id:, first_name: nil, last_name: nil, role_name: nil)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ADMIN_ROLES)

      user = User.find_by(id: id)
      raise_not_found("Users.NotFound", id, "user") if user.nil?

      if role_name.present? && !VALID_ROLES.include?(role_name)
        raise_execution_error(code: "Users.InvalidRole", detail: "Role must be one of: #{VALID_ROLES.join(', ')}", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end

      if target_user_admin_or_above?(user) && !current_user_superadmin?
        raise_execution_error(code: "Users.Forbidden", detail: "Only superadmins can modify admin users.", status: 403, type: "https://tools.ietf.org/html/rfc7231#section-6.5.3")
      end

      ActiveRecord::Base.transaction do
        user.first_name = first_name if first_name.present?
        user.last_name = last_name if last_name.present?
        user.updated_by_id = current_user_id
        user.save!

        if role_name.present?
          user.roles = []
          user.add_role(role_name.to_sym)
        end
      end

      { success: true }
    rescue ActiveRecord::RecordInvalid => e
      raise_execution_error(code: "Users.UpdateFailed", detail: e.record.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    rescue GraphQL::ExecutionError
      raise
    rescue StandardError => e
      Rails.logger.error("UpdateUser failed: #{e.class} - #{e.message}")
      raise_execution_error(code: "Users.UpdateFailed", detail: "Failed to update user.", status: 500, type: "https://tools.ietf.org/html/rfc7231#section-6.6.1")
    end
  end
end
