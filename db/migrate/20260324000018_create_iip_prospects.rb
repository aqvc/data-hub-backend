class CreateIipProspects < ActiveRecord::Migration[7.0]
  def change
    create_table :iip_prospects, id: :uuid do |t|
      t.string :prospect_job_id, null: false
      t.string :investment_vehicle_id, null: false
      t.string :organization_contact_id, null: false
      t.string :status, null: false
      t.text :rejection_reason
      t.text :rejection_reason_qa
      t.text :rejection_reason_qa_code
      t.text :rejection_reason_code
      t.decimal :matched_score
      t.boolean :warm_intro_requested, null: false
      t.text :data_manager_comment
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :iip_prospects, [:created_by_id]
    # add_index :iip_prospects, [:investment_vehicle_id]
    # add_index :iip_prospects, [:organization_contact_id]
    # add_index :iip_prospects, [:prospect_job_id]
    # add_index :iip_prospects, [:updated_by_id]
  end
end
