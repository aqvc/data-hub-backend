class CreateRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :regions, id: :uuid do |t|
      t.text :name, null: false
      t.text :code, null: false
      t.text :description
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
  end
end
