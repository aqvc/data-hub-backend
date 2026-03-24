module Mutations
  class Logout < Mutations::BaseMutation
    field :success, Boolean, null: false

    def resolve
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)
      controller.reset_session
      { success: true }
    rescue GraphQL::ExecutionError
      raise
    rescue StandardError
      { success: false }
    end
  end
end
