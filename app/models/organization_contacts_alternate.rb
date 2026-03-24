class OrganizationContactsAlternate < ApplicationRecord

  belongs_to :alternate_contact, class_name: "OrganizationContact", foreign_key: :alternate_contact_id
  belongs_to :contact, class_name: "OrganizationContact", foreign_key: :contact_id
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

end
