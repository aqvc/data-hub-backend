module Mutations
  class UpdateInvestmentEntity < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :investment_entity, GraphQL::Types::JSON, required: false
    argument :proof_points, [GraphQL::Types::JSON], required: false

    field :success, Boolean, null: false

    def resolve(id:, investment_entity: nil, proof_points: nil)
      authorize_roles!(*GraphqlSupport::AuthHelpers::ALL_ROLES)

      entity = InvestmentEntity.find_by(id: id)
      raise_not_found("InvestmentEntities.NotFound", id, "investment entity") if entity.nil?

      attrs = extract_model_attributes(scoped_payload(investment_entity, :investment_entity, :investmentEntity))
      headquarters_country_id = attrs.delete("headquarters_country")
      headquarters_city = attrs.delete("headquarters_city")
      headquarters_address_line1 = attrs.delete("headquarters_address_line1")
      assign_filtered_attributes(entity, attrs)
      entity.updated_by_id = current_user_id if entity.respond_to?(:updated_by_id=)
      entity.updated_at_utc = Time.now.utc if entity.respond_to?(:updated_at_utc=)

      ActiveRecord::Base.transaction do
        entity.save!
        sync_headquarters_location!(
          entity,
          country_id: headquarters_country_id,
          city: headquarters_city,
          address_line1: headquarters_address_line1
        )
        persist_proof_points!(proof_points, "investment_entity_id" => entity.id)
      end

      { success: true }
    rescue ActiveRecord::RecordInvalid => e
      raise_execution_error(code: "InvestmentEntities.UpdateFailed", detail: e.record.errors.full_messages.join(", "), status: 400, type: "https://tools.ietf.org/html/rfc7231#section-6.5.1")
    end

    private

    def sync_headquarters_location!(entity, country_id:, city:, address_line1:)
      return if country_id.nil? && city.nil? && address_line1.nil?

      normalized_country_id = country_id.to_s.strip
      normalized_city = city.to_s
      normalized_address_line1 = address_line1.to_s

      location = entity.headquarters_address
      if location.nil?
        return if normalized_country_id.blank?

        location = Location.create!(
          country_id: normalized_country_id,
          city: normalized_city,
          address_line1: normalized_address_line1,
          location_type: "primary",
          created_by_id: current_user_id || entity.created_by_id,
          created_at_utc: Time.now.utc
        )
        entity.headquarters_address_id = location.id
        entity.save!
        return
      end

      location.country_id = normalized_country_id if country_id.present? && normalized_country_id.present?
      location.city = normalized_city unless city.nil?
      location.address_line1 = normalized_address_line1 unless address_line1.nil?
      location.updated_by_id = current_user_id if location.respond_to?(:updated_by_id=)
      location.updated_at_utc = Time.now.utc if location.respond_to?(:updated_at_utc=)
      location.save! if location.changed?
    end
  end
end
