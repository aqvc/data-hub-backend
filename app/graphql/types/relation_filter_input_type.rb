module Types
  class RelationFilterInputType < Types::BaseInputObject
    argument :investor_id, ID, required: false
    argument :investment_vehicle_id, ID, required: false
    argument :investment_strategy_id, ID, required: false
    argument :investor_contact_id, ID, required: false
    argument :investment_entity_id, ID, required: false
  end
end
