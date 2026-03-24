module JwtAuthentication
  extend ActiveSupport::Concern

  def current_user
    return @current_user if defined?(@current_user)

    user_id = session[:current_user_id]
    @current_user = user_id.present? ? User.find_by(id: user_id) : nil
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_with_roles!(*allowed_roles)
    unless user_signed_in?
      render_problem(
        code: "Auth.MissingSession",
        detail: "No active session.",
        type: "https://tools.ietf.org/html/rfc7235#section-3.1",
        status: 401
      )
      return false
    end

    roles = session[:current_user_roles].presence || current_user.roles.pluck(:name)

    return true if (roles & allowed_roles).any?

    render_problem(
      code: "Auth.Forbidden",
      detail: "You are not authorized to perform this action.",
      type: "https://tools.ietf.org/html/rfc7231#section-6.5.3",
      status: 403
    )
    false
  end
end
