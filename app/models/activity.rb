class Activity < ApplicationRecord

  self.inheritance_column = :_type_disabled

  belongs_to :organization_contact
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :engagements

  TYPES = %w[
    added_as_follower
    added_to_campaign
    call
    email_sent
    exported
    invited_to_event
    linked_in_connection_sent
    profile_shared
    system_notification
    wizard_sent
  ].freeze

  STATUSES = %w[cancelled completed in_progress pending].freeze

  enum :type, TYPES.zip(TYPES).to_h, prefix: true
  enum :status, STATUSES.zip(STATUSES).to_h, prefix: true

end
