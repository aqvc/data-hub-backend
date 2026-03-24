class CreateCities < ActiveRecord::Migration[7.0]
  def change
    create_table :cities, id: :uuid do |t|
      t.string :name, null: false
      t.string :country_id, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :cities, [:country_id]
  end
end
