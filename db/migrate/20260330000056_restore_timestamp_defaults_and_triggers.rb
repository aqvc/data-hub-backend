class RestoreTimestampDefaultsAndTriggers < ActiveRecord::Migration[7.0]
  TIMESTAMP_DEFAULT_SQL = "CURRENT_TIMESTAMP".freeze
  TRIGGER_FUNCTION_NAME = "set_timestamp_column_to_current_timestamp".freeze

  def up
    create_timestamp_trigger_function

    timestamp_tables.each do |table_name, columns|
      if columns.include?("created_at")
        change_column_default table_name, :created_at, -> { TIMESTAMP_DEFAULT_SQL }
      end

      if columns.include?("created_at_utc")
        change_column_default table_name, :created_at_utc, -> { TIMESTAMP_DEFAULT_SQL }
      end

      if columns.include?("updated_at")
        change_column_default table_name, :updated_at, -> { TIMESTAMP_DEFAULT_SQL }
        attach_timestamp_trigger(table_name, "updated_at")
      end

      if columns.include?("updated_at_utc")
        change_column_default table_name, :updated_at_utc, -> { TIMESTAMP_DEFAULT_SQL }
        attach_timestamp_trigger(table_name, "updated_at_utc")
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Timestamp defaults cannot be restored automatically"
  end

  private

  def timestamp_tables
    connection.tables.filter_map do |table_name|
      columns = connection.columns(table_name).map(&:name)
      timestamp_columns = columns & %w[created_at updated_at created_at_utc updated_at_utc]
      next if timestamp_columns.empty?

      [table_name, timestamp_columns]
    end
  end

  def create_timestamp_trigger_function
    execute <<~SQL
      CREATE OR REPLACE FUNCTION #{TRIGGER_FUNCTION_NAME}()
      RETURNS trigger AS $$
      BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<~SQL
      CREATE OR REPLACE FUNCTION #{TRIGGER_FUNCTION_NAME}_utc()
      RETURNS trigger AS $$
      BEGIN
        NEW.updated_at_utc = CURRENT_TIMESTAMP;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def attach_timestamp_trigger(table_name, column_name)
    trigger_name = timestamp_trigger_name(table_name, column_name)
    function_name = column_name == "updated_at" ? TRIGGER_FUNCTION_NAME : "#{TRIGGER_FUNCTION_NAME}_utc"

    execute <<~SQL
      DROP TRIGGER IF EXISTS #{trigger_name} ON #{quote_table_name(table_name)};
      CREATE TRIGGER #{trigger_name}
      BEFORE UPDATE ON #{quote_table_name(table_name)}
      FOR EACH ROW
      EXECUTE FUNCTION #{function_name}();
    SQL
  end

  def timestamp_trigger_name(table_name, column_name)
    "set_#{table_name}_#{column_name}"
  end
end
