class CreateFieldHistory < ActiveRecord::Migration[7.0]
  def change
    create_table :field_history, id: :uuid do |t|
      t.string :investor_id
      t.string :investment_vehicle_id
      t.string :investment_strategy_id
      t.string :investor_contact_id
      t.string :investment_entity_id
      t.text :field_id, null: false
      t.text :criteria_name
      t.text :criteria_value_old
      t.text :criteria_value_new
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :field_history, [:created_by_id]
    # add_index :field_history, [:investment_entity_id]
    # add_index :field_history, [:investment_strategy_id]
    # add_index :field_history, [:investment_vehicle_id]
    # add_index :field_history, [:investor_contact_id]
    # add_index :field_history, [:investor_id]
    # add_index :field_history, [:updated_by_id]
  end
end
