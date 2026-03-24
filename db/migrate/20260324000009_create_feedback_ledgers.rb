class CreateFeedbackLedgers < ActiveRecord::Migration[7.0]
  def change
    create_table :feedback_ledgers, id: :uuid do |t|
      t.string :proof_ledger_id, null: false
      t.string :prospect_job_id, null: false
      t.text :criteria_name
      t.text :criteria_value
      t.text :proof_text
      t.text :feedback
      t.integer :feedback_score
      t.datetime :feedback_date
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :feedback_ledgers, [:created_by_id]
    # add_index :feedback_ledgers, [:proof_ledger_id]
    # add_index :feedback_ledgers, [:prospect_job_id]
    # add_index :feedback_ledgers, [:updated_by_id]
  end
end
