class CreateInvestmentVehiclesInvestmentStrategies < ActiveRecord::Migration[7.0]
  def change
    create_table :investment_vehicles_investment_strategies, id: false do |t|
      t.string :investment_vehicle_id, null: false
      t.string :investment_strategy_id, null: false
    end
    # add_index :investment_vehicles_investment_strategies, [:investment_strategy_id]
  end
end
