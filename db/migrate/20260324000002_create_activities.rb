class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities, id: :uuid do |t|
      t.string :organization_contact_id, null: false
      t.text :activity_name, null: false
      t.text :description
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.integer :reference_id
      t.string :type, null: false
      t.string :status, null: false
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :activities, [:created_by_id]
    # add_index :activities, [:organization_contact_id]
    # add_index :activities, [:updated_by_id]
  end
end
