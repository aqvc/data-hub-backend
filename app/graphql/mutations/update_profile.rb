module Mutations
  class UpdateProfile < Mutations::BaseMutation
    argument :first_name, String, required: false
    argument :last_name, String, required: false

    field :success, Boolean, null: false

    def resolve(first_name: nil, last_name: nil)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      user = current_user
      raise_execution_error(code: "Auth.MissingSession", detail: "No active session.", status: 401, type: "https://tools.ietf.org/html/rfc7235#section-3.1") if user.nil?

      user.first_name = first_name if first_name.present?
      user.last_name = last_name if last_name.present?
      user.updated_by_id = current_user_id
      user.save!

      { success: true }
    rescue ActiveRecord::RecordInvalid => e
      raise_execution_error(code: "Profile.UpdateFailed", detail: e.record.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    rescue GraphQL::ExecutionError
      raise
    rescue StandardError => e
      ErrorTracker.error("UpdateProfile failed: #{e.class} - #{e.message}")
      raise_execution_error(code: "Profile.UpdateFailed", detail: "Failed to update profile.", status: 500, type: "https://tools.ietf.org/html/rfc7231#section-6.6.1")
    end
  end
end
