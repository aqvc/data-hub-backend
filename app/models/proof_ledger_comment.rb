class ProofLedgerComment < ApplicationRecord

  acts_as_paranoid

  self.table_name = "public.proof_ledger_comments"

  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  belongs_to :proof_ledger_comment_reply_to,
             class_name: "ProofLedgerComment",
             foreign_key: :proof_ledger_comment_reply_to_id,
             optional: true
  belongs_to :investment_entity, optional: true
  belongs_to :investment_strategy, optional: true
  belongs_to :investment_vehicle, optional: true
  belongs_to :investor_contact, optional: true
  belongs_to :investor, optional: true
  has_many :proof_ledger_comments, class_name: "ProofLedgerComment", foreign_key: :proof_ledger_comment_reply_to_id

end
