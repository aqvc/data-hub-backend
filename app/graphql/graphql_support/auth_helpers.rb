module GraphqlSupport
  module AuthHelpers
    ALL_ROLES = %w[superadmin admin data_manager account_manager member].freeze
    SUPERADMIN_ROLE = "superadmin".freeze
    ADMIN_ROLE = "admin".freeze
    ADMIN_ROLES = [SUPERADMIN_ROLE, ADMIN_ROLE].freeze

    private

    def current_user
      controller.current_user
    end

    def current_user_id
      current_user&.id
    end

    def session_roles
      controller.session[:current_user_roles].presence || current_user&.role_names || []
    end

    def authorize_roles!(*allowed_roles)
      if current_user.nil?
        raise_execution_error(
          code: "Auth.MissingSession",
          detail: "No active session.",
          status: 401,
          type: "https://tools.ietf.org/html/rfc7235#section-3.1"
        )
      end

      return true if (session_roles & allowed_roles).any?

      raise_execution_error(
        code: "Auth.Forbidden",
        detail: "You are not authorized to perform this action.",
        status: 403,
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.3"
      )
    end

    def current_user_superadmin?
      session_roles.include?(SUPERADMIN_ROLE)
    end

    def target_user_admin_or_above?(user)
      (user.role_names & ADMIN_ROLES).any?
    end

    def controller
      context[:controller]
    end
  end
end
