class LegacySchemaBaseline < ActiveRecord::Migration[7.0]
  def up
    # Baseline only.
    # Legacy AQVC schema already exists in PostgreSQL (public + auth_hub).
    # Keeping this migration allows standard Rails db:migrate workflow.
  end

  def down
    # No-op
  end
end
