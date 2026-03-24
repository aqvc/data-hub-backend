class CreateProspectJobAuditTrails < ActiveRecord::Migration[7.0]
  def change
    create_table :prospect_job_audit_trails, id: :uuid do |t|
      t.string :prospect_job_id, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :prospect_job_audit_trails, [:created_by_id]
    # add_index :prospect_job_audit_trails, [:prospect_job_id]
    # add_index :prospect_job_audit_trails, [:updated_by_id]
  end
end
