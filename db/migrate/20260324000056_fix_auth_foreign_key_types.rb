class FixAuthForeignKeyTypes < ActiveRecord::Migration[7.0]
  def up
    change_column :user_roles, :user_id, :uuid, using: "user_id::uuid"
    change_column :user_roles, :role_id, :uuid, using: "role_id::uuid"
    change_column :user_refresh_tokens, :user_id, :uuid, using: "user_id::uuid"
  end

  def down
    change_column :user_roles, :user_id, :string
    change_column :user_roles, :role_id, :string
    change_column :user_refresh_tokens, :user_id, :string
  end
end
