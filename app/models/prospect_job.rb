class ProspectJob < ApplicationRecord

  belongs_to :fund_profile
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :owner, class_name: "User", foreign_key: :owner_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :feedback_ledgers
  has_many :ideal_investor_profile_prospect_jobs
  has_many :iip_prospects
  has_many :prospect_job_audit_trails

  enum :status, {
    cancelled: "cancelled",
    completed: "completed",
    in_progress: "in_progress",
    not_started: "not_started",
    on_hold: "on_hold"
  }, prefix: true
  enum :priority, {
    critical: "critical",
    high: "high",
    low: "low",
    medium: "medium"
  }

end
