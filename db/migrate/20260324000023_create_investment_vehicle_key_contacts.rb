class CreateInvestmentVehicleKeyContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :investment_vehicle_key_contacts, id: false do |t|
      t.string :investment_vehicle_id, null: false
      t.string :investor_contact_id, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :investment_vehicle_key_contacts, [:created_by_id]
    # add_index :investment_vehicle_key_contacts, [:investor_contact_id]
    # add_index :investment_vehicle_key_contacts, [:updated_by_id]
  end
end
