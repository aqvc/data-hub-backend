class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries, id: :uuid do |t|
      t.string :region_id, null: false
      t.text :name, null: false
      t.text :iso_code, null: false
      t.text :iso3code, null: false
      t.text :calling_code, null: false
      t.string :currency_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :countries, [:currency_id]
    # add_index :countries, [:region_id]
  end
end
