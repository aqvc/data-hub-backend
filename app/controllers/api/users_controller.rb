module Api
  class UsersController < ApplicationController
    include JwtAuthentication

    ALL_ROLES = GraphqlSupport::AuthHelpers::ALL_ROLES
    ADMIN_ROLE = GraphqlSupport::AuthHelpers::ADMIN_ROLE
    DEFAULT_PASSWORD = "Password123!".freeze

    before_action only: [:logout, :show] do
      authenticate_with_roles!(*ALL_ROLES)
    end
    before_action only: [:create_account_manager] do
      authenticate_with_roles!(ADMIN_ROLE)
    end

    def show
      user = User.find_by(id: params[:id])
      if user.nil?
        return render_problem(
          code: "Users.NotFound",
          detail: "The user with the Id = '#{params[:id]}' was not found",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
          status: 404
        )
      end

      render json: {
        id: user.id,
        email: user.email,
        emailConfirmed: user.email_confirmed,
        createdAt: user.created_at,
        firstName: user.first_name,
        lastName: user.last_name,
        organization: {}
      }, status: :ok
    end

    def login
      email = params[:email].to_s
      password = params[:password].to_s

      user = User.find_by(email: email)
      if user.nil?
        return render_problem(
          code: "Users.NotFoundByEmail",
          detail: "The user with the specified email was not found",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.4",
          status: 404
        )
      end

      unless user.valid_password?(password)
        return render_problem(
          code: "Users.Unauthorized",
          detail: "You are not authorized to perform this action.",
          type: "https://tools.ietf.org/html/rfc7231#section-6.6.1",
          status: 401
        )
      end

      roles = user.role_names
      reset_session
      session[:current_user_id] = user.id
      session[:current_user_roles] = roles

      render json: { authenticated: true, userId: user.id, roles: roles }, status: :ok
    rescue StandardError => e
      ErrorTracker.error("UsersController#login failed: #{e.class} - #{e.message}")
      render_problem(
        code: "Users.AuthenticationFailed",
        detail: "The user authentication failed",
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 400
      )
    end

    def logout
      reset_session
      render json: true, status: :ok
    rescue StandardError
      render json: false, status: :ok
    end

    def create_account_manager
      email = params[:email].to_s.strip
      password = params[:password].to_s
      first_name = params[:firstName].to_s
      last_name = params[:lastName].to_s

      if email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
        return render_problem(
          code: "Users.RegistrationFailed",
          detail: "Email must be a valid email address.",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
          status: 400
        )
      end

      if User.exists?(normalized_email: email.upcase)
        return render_problem(
          code: "Users.EmailNotUnique",
          detail: "The provided email is not unique",
          type: "https://tools.ietf.org/html/rfc7231#section-6.5.8",
          status: 409
        )
      end

      user = nil
      ActiveRecord::Base.transaction do
        user = User.create!(
          email: email,
          user_name: email,
          first_name: first_name,
          last_name: last_name,
          email_confirmed: true,
          password: password.presence || DEFAULT_PASSWORD,
          password_confirmation: password.presence || DEFAULT_PASSWORD,
          security_stamp: SecureRandom.uuid,
          concurrency_stamp: SecureRandom.uuid,
          access_failed_count: 0,
          phone_number_confirmed: false,
          two_factor_enabled: false,
          lockout_enabled: true,
          created_by_id: current_user_id
        )

        user.add_role(:account_manager)
      end

      render json: user.id, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render_problem(
        code: "Users.RegistrationFailed",
        detail: e.record.errors.full_messages.join(", ").presence || "The user registration failed",
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 400
      )
    rescue StandardError
      render_problem(
        code: "Users.RegistrationFailed",
        detail: "The user registration failed",
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1",
        status: 400
      )
    end

    private

    def current_user_id
      current_user.id
    end
  end
end
