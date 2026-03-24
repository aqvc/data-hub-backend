class Engagement < ApplicationRecord

  self.inheritance_column = :_type_disabled

  belongs_to :activity, optional: true
  belongs_to :organization_contact
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

  enum :type, {
    attended_event: "attended_event",
    meeting_scheduled: "meeting_scheduled",
    message_reply: "message_reply",
    opened_email: "opened_email",
    replied_to_email: "replied_to_email",
    soft_commitment_clicked: "soft_commitment_clicked",
    soft_commitment_saved: "soft_commitment_saved",
    viewed_profile: "viewed_profile"
  }, prefix: true
  enum :status, {
    cancelled: "cancelled",
    completed: "completed",
    in_progress: "in_progress",
    pending: "pending"
  }, prefix: true

end
