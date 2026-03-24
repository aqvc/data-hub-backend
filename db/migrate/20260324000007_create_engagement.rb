class CreateEngagement < ActiveRecord::Migration[7.0]
  def change
    create_table :engagement, id: :uuid do |t|
      t.string :organization_contact_id, null: false
      t.text :engagement_name, null: false
      t.datetime :engagement_date
      t.string :activity_id
      t.text :description
      t.text :sentiment_type
      t.text :sentiment_context
      t.integer :reference_id
      t.string :type, null: false
      t.string :status, null: false
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :engagement, [:activity_id]
    # add_index :engagement, [:created_by_id]
    # add_index :engagement, [:organization_contact_id]
    # add_index :engagement, [:updated_by_id]
  end
end
