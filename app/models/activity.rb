class Activity < ApplicationRecord

  self.inheritance_column = :_type_disabled

  belongs_to :organization_contact
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :engagements

  enum :type, {
    added_as_follower: "added_as_follower",
    added_to_campaign: "added_to_campaign",
    call: "call",
    email_sent: "email_sent",
    exported: "exported",
    invited_to_event: "invited_to_event",
    linked_in_connection_sent: "linked_in_connection_sent",
    profile_shared: "profile_shared",
    system_notification: "system_notification",
    wizard_sent: "wizard_sent"
  }, prefix: true
  enum :status, {
    cancelled: "cancelled",
    completed: "completed",
    in_progress: "in_progress",
    pending: "pending"
  }, prefix: true

end
