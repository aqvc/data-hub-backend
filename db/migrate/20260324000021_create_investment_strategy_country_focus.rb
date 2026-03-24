class CreateInvestmentStrategyCountryFocus < ActiveRecord::Migration[7.0]
  def change
    create_table :investment_strategy_country_focus, id: false do |t|
      t.string :investment_strategy_id, null: false
      t.string :country_id, null: false
    end
    # add_index :investment_strategy_country_focus, [:country_id]
  end
end
