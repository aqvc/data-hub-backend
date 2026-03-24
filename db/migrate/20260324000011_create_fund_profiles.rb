class CreateFundProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :fund_profiles, id: :uuid do |t|
      t.string :organization_profile_id, null: false
      t.string :fund_manager_id, null: false
      t.text :fund_name, null: false
      t.string :type, null: false
      t.string :sector_focus, null: false, array: true
      t.string :stage_focus, null: false, array: true
      t.string :geography_focus, null: false, array: true
      t.text :fund_generation
      t.decimal :target_fund_size
      t.integer :vintage_year
      t.string :maturity, null: false
      t.decimal :min_ticket
      t.datetime :close_date
      t.datetime :launch_date
      t.string :fund_structure, null: false
      t.hstore :fees
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :fund_profiles, [:created_by_id]
    # add_index :fund_profiles, [:fund_manager_id]
    # add_index :fund_profiles, [:organization_profile_id]
    # add_index :fund_profiles, [:updated_by_id]
  end
end
