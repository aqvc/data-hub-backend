class CreateIdealInvestorProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :ideal_investor_profiles, id: :uuid do |t|
      t.string :organization_profile_id, null: false
      t.string :name, null: false
      t.string :description
      t.string :iip_status, null: false, default: "active"
      t.datetime :due_date, null: false
      t.integer :target_nr_of_prospects_to_generate, null: false
      t.string :asset_class, null: false, array: true
      t.string :sector_focus, null: false, array: true
      t.string :investor_type, array: true
      t.string :maturity_focus, array: true
      t.string :stage_focus, array: true
      t.decimal :min_check_size, precision: 18, scale: 2
      t.decimal :max_check_size, precision: 18, scale: 2
      t.string :targeting_approach
      t.text :thematic_keywords, array: true
      t.string :briefing
      t.string :fund_profile_id
      t.string :strategy_focus, array: true
      t.string :region_headquarter_id
      t.string :country_headquarter_id
      t.text :city_headquarter
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :ideal_investor_profiles, [:country_headquarter_id]
    # add_index :ideal_investor_profiles, [:created_by_id]
    # add_index :ideal_investor_profiles, [:fund_profile_id]
    # add_index :ideal_investor_profiles, [:name, :organization_profile_id], unique: true
    # add_index :ideal_investor_profiles, [:name]
    # add_index :ideal_investor_profiles, [:organization_profile_id]
    # add_index :ideal_investor_profiles, [:region_headquarter_id]
    # add_index :ideal_investor_profiles, [:updated_by_id]
  end
end
