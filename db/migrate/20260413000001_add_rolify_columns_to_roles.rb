class AddRolifyColumnsToRoles < ActiveRecord::Migration[7.0]
  def change
    change_table :roles do |t|
      t.references :resource, polymorphic: true, type: :uuid
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }, null: false
    end

    add_index :roles, :name
    add_index :roles, [:name, :resource_type, :resource_id]
    add_index :user_roles, [:user_id, :role_id]

    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO roles (name, normalized_name, concurrency_stamp, created_at, updated_at)
          VALUES ('Member', 'MEMBER', gen_random_uuid()::text, NOW(), NOW())
          ON CONFLICT (normalized_name) DO NOTHING;
        SQL
      end
    end
  end
end
