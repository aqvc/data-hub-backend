class AddDeviseToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :encrypted_password, :string, null: false, default: ""
    add_index :users, :email, unique: true
    add_index :users, :normalized_email, unique: true
    add_index :roles, :normalized_name, unique: true
    add_index :user_refresh_tokens, :token, unique: true
  end
end
