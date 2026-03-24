module Mutations
  class UpdateInvestor < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :investor, GraphQL::Types::JSON, required: false
    argument :proof_points, [GraphQL::Types::JSON], required: false

    field :success, Boolean, null: false

    def resolve(id:, investor: nil, proof_points: nil)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      record = Investor.find_by(id: id)
      raise_not_found("Investors.NotFound", id, "investor") if record.nil?

      attrs = extract_model_attributes(investor)
      assign_filtered_attributes(record, attrs)
      record.updated_by_id = current_user_id if record.respond_to?(:updated_by_id=)
      record.updated_at_utc = Time.now.utc if record.respond_to?(:updated_at_utc=)

      ActiveRecord::Base.transaction do
        record.save!
        persist_proof_points!(proof_points, "investor_id" => record.id)
      end

      { success: true }
    rescue ActiveRecord::RecordInvalid => e
      raise_execution_error(code: "Investors.UpdateFailed", detail: e.record.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    end
  end
end
