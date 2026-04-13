module Mutations
  class DeleteUser < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(id:)
      authorize_roles!(GraphqlSupport::AuthHelpers::ADMIN_ROLE)

      user = User.find_by(id: id)
      raise_not_found("Users.NotFound", id, "user") if user.nil?

      if user.id == current_user_id
        raise_execution_error(code: "Users.CannotDeleteSelf", detail: "You cannot delete your own account.", status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
      end

      user.roles = []
      user.destroy!

      { success: true }
    rescue GraphQL::ExecutionError
      raise
    rescue StandardError => e
      Rails.logger.error("DeleteUser failed: #{e.class} - #{e.message}")
      raise_execution_error(code: "Users.DeleteFailed", detail: "Failed to delete user.", status: 500, type: "https://tools.ietf.org/html/rfc7231#section-6.6.1")
    end
  end
end
