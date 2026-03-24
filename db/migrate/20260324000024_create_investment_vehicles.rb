class CreateInvestmentVehicles < ActiveRecord::Migration[7.0]
  def change
    create_table :investment_vehicles, id: :uuid do |t|
      t.string :investor_id, null: false
      t.string :currency_id
      t.string :location_id
      t.string :fund_profile_id
      t.text :name, null: false
      t.text :legal_name
      t.string :type
      t.string :fund_status
      t.string :investing_status
      t.decimal :fund_size
      t.decimal :target_size
      t.integer :vintage_year
      t.datetime :anouncement_date
      t.decimal :min_lp_ticket
      t.text :generation
      t.decimal :aum
      t.decimal :dry_powder_in_currency
      t.decimal :dry_powder_in_usd
      t.decimal :hurdle_rate
      t.string :management_fee_id
      t.text :other_fees
      t.text :special_terms
      t.integer :target_investments
      t.integer :number_of_investments
      t.decimal :carried_interest
      t.boolean :super_carry
      t.decimal :super_carry_threshold
      t.decimal :super_carry_size
      t.boolean :catch_up
      t.boolean :claw_back
      t.integer :annual_planned_investments
      t.decimal :annual_planned_allocation_in_currency
      t.datetime :last_investment
      t.decimal :invested_capital
      t.string :key_person_id
      t.decimal :recycling
      t.string :distribution_waterfall
      t.datetime :target_closing_date
      t.datetime :first_close_date
      t.datetime :final_close_date
      t.datetime :fundraising_start_date
      t.integer :investment_period
      t.decimal :gp_commitment
      t.integer :jurisdiction
      t.string :marketing_geographies_id
      t.integer :fund_duration
      t.integer :extended_fund_term
      t.integer :number_of_investing_partners
      t.text :description
      t.integer :verifications, array: true
      t.text :logo_url
      t.text :favicon_url
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :investment_vehicles, [:created_by_id]
    # add_index :investment_vehicles, [:currency_id]
    # add_index :investment_vehicles, [:fund_profile_id]
    # add_index :investment_vehicles, [:investor_id]
    # add_index :investment_vehicles, [:key_person_id]
    # add_index :investment_vehicles, [:location_id]
    # add_index :investment_vehicles, [:management_fee_id]
    # add_index :investment_vehicles, [:marketing_geographies_id]
    # add_index :investment_vehicles, [:updated_by_id]
  end
end
