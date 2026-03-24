class OrganizationMember < ApplicationRecord

  belongs_to :organization_profile
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  belongs_to :user

  enum :organization_member_type, {
    admin: "admin",
    member: "member",
    owner: "owner"
  }

end
