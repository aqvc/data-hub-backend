class IipProspectInvestorContact < ApplicationRecord

  belongs_to :iip_prospects, class_name: "IipProspect", foreign_key: :iip_prospects_id
  belongs_to :investor_contact
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

end
