module Mutations
  class DeleteInvestor < Mutations::BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(id:)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      investor = Investor.find_by(id: id)
      raise_not_found("Investors.NotFound", id, "investor") if investor.nil?

      ActiveRecord::Base.transaction do
        # Soft-delete the investor; owned has_many associations configured with
        # `dependent: :destroy` are cascaded by ActiveRecord, and because those
        # models also `acts_as_paranoid`, the cascade becomes a soft-delete too.
        # Vehicles are intentionally excluded from the cascade per product
        # requirements.
        investor.destroy!
      end

      { success: true }
    rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::InvalidForeignKey => e
      raise_execution_error(
        code: "Investors.DeleteFailed",
        detail: e.message,
        status: 400,
        type: "https://tools.ietf.org/html/rfc7231#section-6.5.1"
      )
    end
  end
end
