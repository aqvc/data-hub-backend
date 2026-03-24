class CreateInvestments < ActiveRecord::Migration[7.0]
  def change
    create_table :investments, id: :uuid do |t|
      t.string :investment_vehicle_id, null: false
      t.string :investment_entity_id, null: false
      t.string :currency_id
      t.string :asset_class
      t.datetime :investment_date
      t.decimal :commitment_amount
      t.decimal :called_amount
      t.decimal :distributed_amount
      t.boolean :highlighted, null: false
      t.string :investment_strategy_id
      t.string :status
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :investments, [:created_by_id]
    # add_index :investments, [:investment_entity_id]
    # add_index :investments, [:investment_strategy_id]
    # add_index :investments, [:investment_vehicle_id]
    # add_index :investments, [:updated_by_id]
  end
end
