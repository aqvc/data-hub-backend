class CreateInvestmentEntities < ActiveRecord::Migration[7.0]
  def change
    create_table :investment_entities, id: :uuid do |t|
      t.string :location_id
      t.string :investment_vehicle_id, null: false
      t.text :name
      t.text :legal_name
      t.string :legal_status
      t.text :website_url
      t.text :favicon_url
      t.text :logo_url
      t.string :sector
      t.string :type
      t.string :headquarters_address_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :investment_entities, [:created_by_id]
    # add_index :investment_entities, [:headquarters_address_id]
    # add_index :investment_entities, [:investment_vehicle_id]
    # add_index :investment_entities, [:location_id]
    # add_index :investment_entities, [:updated_by_id]
  end
end
