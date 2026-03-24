class CreateCurrencies < ActiveRecord::Migration[7.0]
  def change
    create_table :currencies, id: :uuid do |t|
      t.text :name, null: false
      t.string :symbol
      t.string :code
      t.integer :decimal_places
      t.boolean :is_active, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :currencies, [:code], unique: true
  end
end
