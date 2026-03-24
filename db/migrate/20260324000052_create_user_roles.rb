class CreateUserRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :user_roles, id: false do |t|
      t.string :user_id, null: false
      t.string :role_id, null: false
    end
    # add_index :user_roles, [:role_id]
  end
end
