class MergeUserDetailsIntoUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    if table_exists?(:user_details_hub)
      execute(<<~SQL)
        UPDATE users
        SET first_name = ud.first_name,
            last_name  = ud.last_name
        FROM user_details_hub ud
        WHERE ud.id::text = users.id::text
      SQL

      drop_table :user_details_hub
    end

    rename_column :users, :created_at_utc, :created_at
    rename_column :users, :updated_at_utc, :updated_at

    # Replace the legacy *_utc updated_at trigger with the standard one so
    # ActiveRecord-managed timestamps continue to auto-update.
    execute <<~SQL
      DROP TRIGGER IF EXISTS set_users_updated_at_utc ON users;
      DROP TRIGGER IF EXISTS set_users_updated_at ON users;
      CREATE TRIGGER set_users_updated_at
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION set_timestamp_column_to_current_timestamp();
    SQL
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS set_users_updated_at ON users;
      DROP TRIGGER IF EXISTS set_users_updated_at_utc ON users;
      CREATE TRIGGER set_users_updated_at_utc
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION set_timestamp_column_to_current_timestamp_utc();
    SQL

    rename_column :users, :updated_at, :updated_at_utc
    rename_column :users, :created_at, :created_at_utc

    create_table :user_details_hub, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :first_name
      t.string :last_name
      t.datetime :created_at_utc, default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.datetime :updated_at_utc, default: -> { "CURRENT_TIMESTAMP" }
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end

    execute(<<~SQL)
      INSERT INTO user_details_hub (id, first_name, last_name, created_by_id)
      SELECT id, first_name, last_name, created_by_id
      FROM users
      WHERE first_name IS NOT NULL OR last_name IS NOT NULL
    SQL

    remove_column :users, :last_name
    remove_column :users, :first_name
  end
end
