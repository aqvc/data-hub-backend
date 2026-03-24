class CreateUserLogins < ActiveRecord::Migration[7.0]
  def change
    create_table :user_logins, id: false do |t|
      t.text :login_provider, null: false
      t.text :provider_key, null: false
      t.text :provider_display_name
      t.string :user_id, null: false
    end
    # add_index :user_logins, [:user_id]
  end
end
