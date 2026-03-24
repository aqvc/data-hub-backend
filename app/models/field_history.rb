class FieldHistory < ApplicationRecord

  belongs_to :investment_entity, optional: true
  belongs_to :investment_strategy, optional: true
  belongs_to :investment_vehicle, optional: true
  belongs_to :investor_contact, optional: true
  belongs_to :investor, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

end
