class CreateProofLedgers < ActiveRecord::Migration[7.0]
  def change
    create_table :proof_ledgers, id: :uuid do |t|
      t.string :investor_id
      t.string :investment_vehicle_id
      t.string :investment_strategy_id
      t.string :investor_contact_id
      t.string :investment_entity_id
      t.text :field_id, null: false
      t.string :proof_type, null: false
      t.text :source_name
      t.text :reference
      t.text :raw_data_url
      t.text :data_project_id
      t.datetime :observed
      t.text :criteria_name
      t.text :criteria_value_old
      t.text :criteria_value_new
      t.text :proof_text
      t.decimal :certainty_score
      t.string :status, null: false
      t.text :internal_comment
      t.integer :version, null: false
      t.text :rational
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :proof_ledgers, [:created_by_id]
    # add_index :proof_ledgers, [:investment_entity_id]
    # add_index :proof_ledgers, [:investment_strategy_id]
    # add_index :proof_ledgers, [:investment_vehicle_id]
    # add_index :proof_ledgers, [:investor_contact_id]
    # add_index :proof_ledgers, [:investor_id]
    # add_index :proof_ledgers, [:updated_by_id]
  end
end
