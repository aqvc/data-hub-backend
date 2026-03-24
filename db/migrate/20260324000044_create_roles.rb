class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name
      t.string :normalized_name
      t.text :concurrency_stamp
    end
    # add_index :roles, [:normalized_name], unique: true
  end
end
