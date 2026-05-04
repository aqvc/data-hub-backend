class Engagement < ApplicationRecord

  self.inheritance_column = :_type_disabled

  belongs_to :activity, optional: true
  belongs_to :organization_contact
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

  TYPES = %w[
    attended_event
    meeting_scheduled
    message_reply
    opened_email
    replied_to_email
    soft_commitment_clicked
    soft_commitment_saved
    viewed_profile
  ].freeze

  STATUSES = %w[cancelled completed in_progress pending].freeze

  enum :type, TYPES.zip(TYPES).to_h, prefix: true
  enum :status, STATUSES.zip(STATUSES).to_h, prefix: true

end
