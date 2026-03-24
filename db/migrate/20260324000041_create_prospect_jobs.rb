class CreateProspectJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :prospect_jobs, id: :uuid do |t|
      t.string :owner_id, null: false
      t.string :ideal_investor_profile_prospect_job_id, null: false
      t.string :fund_profile_id, null: false
      t.text :name, null: false
      t.datetime :due_date
      t.column :data_manager_time_spent, :interval
      t.column :account_manager_time_spent, :interval
      t.text :data_manager
      t.text :account_manager
      t.string :status, null: false
      t.integer :number_of_prospects, null: false
      t.integer :number_of_bonus_prospects, null: false
      t.decimal :cost_per_prospect, null: false
      t.string :priority, null: false
      t.datetime :started_at
      t.datetime :delivered_at
      t.decimal :qa_rejection_rate, null: false
      t.decimal :rejection_rate, null: false
      t.decimal :contacts_rate, null: false
      t.decimal :warm_intro_request_rate, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :prospect_jobs, [:created_by_id]
    # add_index :prospect_jobs, [:fund_profile_id]
    # add_index :prospect_jobs, [:owner_id]
    # add_index :prospect_jobs, [:updated_by_id]
  end
end
