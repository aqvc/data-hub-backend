module GraphqlApi
  class ProofLedgerFilterService
    RELATION_KEYS = {
      investor_id: :investor_id,
      investment_vehicle_id: :investment_vehicle_id,
      investment_strategy_id: :investment_strategy_id,
      investor_contact_id: :investor_contact_id,
      investment_entity_id: :investment_entity_id
    }.freeze

    def relation_from(filter)
      relation_pairs = RELATION_KEYS.filter_map do |column, key|
        value = filter.to_h[key.to_s].presence || filter.to_h[key]
        [column, value] if value.present?
      end

      return nil if relation_pairs.empty? || relation_pairs.size > 1

      key, value = relation_pairs.first
      { key => value }
    end
  end
end
