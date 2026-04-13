class ProofLedger < ApplicationRecord

  acts_as_paranoid

  self.table_name = "public.proof_ledgers"

  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  belongs_to :investment_entity, optional: true
  belongs_to :investment_strategy, optional: true
  belongs_to :investment_vehicle, optional: true
  belongs_to :investor_contact, optional: true
  belongs_to :investor, optional: true
  has_many :feedback_ledgers

  enum :proof_type, {
    ai_research: "ai_research",
    email: "email",
    list: "list",
    manual: "manual",
    meeting: "meeting",
    news: "news",
    provider: "provider",
    proxy: "proxy",
    transcript: "transcript",
    website: "website",
    wizard: "wizard"
  }
  enum :status, {
    active: "active",
    pending: "pending",
    rejected: "rejected"
  }, prefix: true

end
