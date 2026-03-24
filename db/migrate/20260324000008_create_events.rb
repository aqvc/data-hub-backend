class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events, id: :uuid do |t|
      t.text :name, null: false
      t.string :investor_id
    end
    # add_index :events, [:investor_id]
  end
end
