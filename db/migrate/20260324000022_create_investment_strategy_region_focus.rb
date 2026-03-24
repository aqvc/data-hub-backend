class CreateInvestmentStrategyRegionFocus < ActiveRecord::Migration[7.0]
  def change
    create_table :investment_strategy_region_focus, id: false do |t|
      t.string :investment_strategy_id, null: false
      t.string :region_id, null: false
    end
    # add_index :investment_strategy_region_focus, [:region_id]
  end
end
