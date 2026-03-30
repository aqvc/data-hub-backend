class RestoreUuidPrimaryKeyDefaults < ActiveRecord::Migration[7.0]
  UUID_DEFAULT_FUNCTION = "gen_random_uuid()".freeze

  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    uuid_primary_key_tables.each do |table_name, primary_key|
      change_column_default table_name, primary_key, -> { UUID_DEFAULT_FUNCTION }
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "UUID primary key defaults cannot be restored automatically"
  end

  private

  def uuid_primary_key_tables
    connection.tables.filter_map do |table_name|
      primary_key = connection.primary_key(table_name)
      next if primary_key.blank?

      id_column = connection.columns(table_name).find { |column| column.name == primary_key }
      next unless id_column&.sql_type == "uuid"
      next if id_column.default_function == UUID_DEFAULT_FUNCTION

      [table_name, primary_key]
    end
  end
end
