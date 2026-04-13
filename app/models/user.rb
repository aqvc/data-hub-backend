class User < ApplicationRecord
  rolify role_join_table_name: "user_roles"

  devise :database_authenticatable, :validatable, :invitable

  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id, optional: true
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

  has_many :refresh_tokens
  has_many :created_users, class_name: "User", foreign_key: :created_by_id, dependent: nil
  has_many :updated_users, class_name: "User", foreign_key: :updated_by_id, dependent: nil
  has_many :created_activities, class_name: "Activity", foreign_key: :created_by_id, dependent: nil
  has_many :updated_activities, class_name: "Activity", foreign_key: :updated_by_id, dependent: nil
  has_many :created_engagements, class_name: "Engagement", foreign_key: :created_by_id, dependent: nil
  has_many :updated_engagements, class_name: "Engagement", foreign_key: :updated_by_id, dependent: nil
  has_many :created_fund_profiles, class_name: "FundProfile", foreign_key: :created_by_id, dependent: nil
  has_many :updated_fund_profiles, class_name: "FundProfile", foreign_key: :updated_by_id, dependent: nil
  has_many :owned_organization_contacts, class_name: "OrganizationContact", foreign_key: :owner_id, dependent: nil
  has_many :created_organization_contacts, class_name: "OrganizationContact", foreign_key: :created_by_id, dependent: nil
  has_many :updated_organization_contacts, class_name: "OrganizationContact", foreign_key: :updated_by_id, dependent: nil
  has_many :organization_members
  has_many :owned_prospect_jobs, class_name: "ProspectJob", foreign_key: :owner_id, dependent: nil
  has_many :created_prospect_jobs, class_name: "ProspectJob", foreign_key: :created_by_id, dependent: nil
  has_many :updated_prospect_jobs, class_name: "ProspectJob", foreign_key: :updated_by_id, dependent: nil

  before_validation :normalize_auth_fields

  def role_names
    roles.pluck(:name)
  end

  private

  def normalize_auth_fields
    normalized_email_value = email.to_s.strip.downcase
    return if normalized_email_value.blank?

    self.email = normalized_email_value
    self.user_name = normalized_email_value if user_name.blank?
    self.normalized_email = normalized_email_value.upcase
    self.normalized_user_name = user_name.to_s.upcase if user_name.present?
  end
end
