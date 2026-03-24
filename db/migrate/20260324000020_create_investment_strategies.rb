class CreateInvestmentStrategies < ActiveRecord::Migration[7.0]
  def change
    create_table :investment_strategies, id: :uuid do |t|
      t.string :investor_id
      t.string :investor_contact_id
      t.text :name
      t.decimal :aum
      t.integer :target_investments
      t.integer :experience_in_years
      t.text :program
      t.string :investor_type_focus, null: false, default: [], array: true
      t.string :sector_investment_focus, null: false, default: [], array: true
      t.string :maturity_focus, null: false, default: [], array: true
      t.string :stage_focus, null: false, default: [], array: true
      t.string :asset_class_focus, null: false, default: [], array: true
      t.decimal :min_check_size
      t.decimal :max_check_size
      t.decimal :ideal_check_size
      t.decimal :min_fund_size
      t.decimal :max_fund_size
      t.decimal :revenue_min
      t.decimal :revenue_max
      t.decimal :profit_min
      t.decimal :profit_max
      t.decimal :valuation_min
      t.decimal :valuation_max
      t.decimal :deal_size_min
      t.decimal :deal_size_max
      t.integer :min_investment_horizon
      t.integer :max_investment_horizon
      t.decimal :irr_min
      t.decimal :dpi_min
      t.decimal :tvpi_min
      t.decimal :moic_min
      t.decimal :total_capital_raised_min
      t.decimal :total_capital_raised_max
      t.string :business_type
      t.string :revenue_type
      t.string :founder_type
      t.string :asset_type
      t.decimal :target_ownership_min
      t.decimal :target_ownership_max
      t.boolean :leading_rounds
      t.boolean :following_rounds
      t.boolean :convertible_loans
      t.boolean :debt
      t.boolean :re_up_behavior
      t.decimal :min_founder_stake
      t.decimal :max_fund_commitment
      t.boolean :board_seat_requirement
      t.boolean :board_observer_requirement
      t.text :things_what_get_us_excited
      t.text :common_reasons_why_we_pass
      t.text :how_we_help_investments
      t.decimal :follow_on_reserve_ratio
      t.string :strategy_focus, null: false, default: [], array: true
      t.string :region_headquarter_id
      t.string :country_headquarter_id
      t.text :city_headquarter
      t.text :events_attendance, array: true
      t.text :keywords, array: true
      t.integer :risk_tolerance
      t.text :esg_preferences, array: true
      t.boolean :esg_sdg_focus
      t.hstore :geo_targeting
      t.hstore :score_weightings
      t.text :note
      t.datetime :last_modified_at
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :investment_strategies, [:country_headquarter_id]
    # add_index :investment_strategies, [:created_by_id]
    # add_index :investment_strategies, [:investor_contact_id]
    # add_index :investment_strategies, [:investor_id]
    # add_index :investment_strategies, [:region_headquarter_id]
    # add_index :investment_strategies, [:updated_by_id]
  end
end
