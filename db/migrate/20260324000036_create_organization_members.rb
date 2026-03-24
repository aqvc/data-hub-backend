class CreateOrganizationMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :organization_members, id: :uuid do |t|
      t.string :user_id, null: false
      t.string :organization_profile_id, null: false
      t.string :organization_member_type, null: false
      t.datetime :joined_at, null: false, default: -> { "(now() AT TIME ZONE 'utc'::text)" }
      t.boolean :is_active, null: false, default: true
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :organization_members, [:created_by_id]
    # add_index :organization_members, [:organization_profile_id]
    # add_index :organization_members, [:updated_by_id]
    # add_index :organization_members, [:user_id, :organization_profile_id], unique: true
  end
end
