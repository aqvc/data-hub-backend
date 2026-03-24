class IipProspect < ApplicationRecord

  belongs_to :investment_vehicle
  belongs_to :organization_contact
  belongs_to :prospect_job
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :iip_prospect_investor_contacts, class_name: "IipProspectInvestorContact", foreign_key: :iip_prospects_id

  enum :status, {
    approved: "approved",
    pending: "pending",
    rejected: "rejected"
  }, prefix: true

end
