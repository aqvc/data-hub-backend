class InvestorContact < ApplicationRecord

  self.table_name = "public.investor_contacts"

  belongs_to :investor
  belongs_to :location, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :field_histories
  has_many :fund_profiles, class_name: "FundProfile", foreign_key: :fund_manager_id
  has_many :iip_prospect_investor_contacts
  has_many :investment_strategies
  has_many :investment_vehicle_key_contacts
  has_many :investment_vehicles, class_name: "InvestmentVehicle", foreign_key: :key_person_id
  has_many :investor_contacts_relateds, class_name: "InvestorContactsRelated", foreign_key: :contact_id
  has_many :investor_contacts_relateds, class_name: "InvestorContactsRelated", foreign_key: :related_contact_id
  has_many :investors, class_name: "Investor", foreign_key: :primary_contact_id
  has_many :organization_contacts, class_name: "OrganizationContact", foreign_key: :investor_contact_reference_id
  has_many :proof_ledger_comments
  has_many :proof_ledgers

  enum :preferred_contact_method, {
    email: "email",
    in_person: "in_person",
    phone: "phone",
    social_media: "social_media",
    video_call: "video_call"
  }

end
