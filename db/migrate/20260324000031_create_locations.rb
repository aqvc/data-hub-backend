class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations, id: :uuid do |t|
      t.string :country_id, null: false
      t.text :street
      t.text :address_line1
      t.text :address_line2
      t.text :postal_code
      t.text :neighborhood
      t.text :city
      t.string :location_type, null: false
      t.decimal :latitude
      t.decimal :longitude
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :locations, [:country_id]
    # add_index :locations, [:created_by_id]
    # add_index :locations, [:updated_by_id]
  end
end
