class CreateIdealInvestorProfileProspectJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :ideal_investor_profile_prospect_jobs, id: :uuid do |t|
      t.string :prospect_job_id, null: false
      t.string :ideal_investor_profile_id, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :ideal_investor_profile_prospect_jobs, [:created_by_id]
    # add_index :ideal_investor_profile_prospect_jobs, [:ideal_investor_profile_id]
    # add_index :ideal_investor_profile_prospect_jobs, [:prospect_job_id], unique: true
    # add_index :ideal_investor_profile_prospect_jobs, [:updated_by_id]
  end
end
