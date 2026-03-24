class OrganizationProfile < ApplicationRecord

  self.table_name = "public.organization_profiles"

  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  belongs_to :user, optional: true
  has_many :fund_profiles
  has_many :ideal_investor_profiles
  has_many :investors
  has_many :organization_contacts
  has_many :organization_marketing_details
  has_many :organization_members

  enum :organization_status, {
    active: "active",
    inactive: "inactive"
  }

end
