class CreateProofLedgerComments < ActiveRecord::Migration[7.0]
  def change
    create_table :proof_ledger_comments, id: :uuid do |t|
      t.string :investor_id
      t.string :investment_vehicle_id
      t.string :investment_strategy_id
      t.string :investor_contact_id
      t.string :investment_entity_id
      t.string :proof_ledger_comment_reply_to_id
      t.text :field_id, null: false
      t.text :comment, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :proof_ledger_comments, [:created_by_id]
    # add_index :proof_ledger_comments, [:investment_entity_id]
    # add_index :proof_ledger_comments, [:investment_strategy_id]
    # add_index :proof_ledger_comments, [:investment_vehicle_id]
    # add_index :proof_ledger_comments, [:investor_contact_id]
    # add_index :proof_ledger_comments, [:investor_id]
    # add_index :proof_ledger_comments, [:proof_ledger_comment_reply_to_id]
    # add_index :proof_ledger_comments, [:updated_by_id]
  end
end
