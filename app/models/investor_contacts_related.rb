class InvestorContactsRelated < ApplicationRecord

  belongs_to :contact, class_name: "InvestorContact", foreign_key: :contact_id
  belongs_to :related_contact, class_name: "InvestorContact", foreign_key: :related_contact_id
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

end
