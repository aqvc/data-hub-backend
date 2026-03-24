class CreateEfMigrationsHistory < ActiveRecord::Migration[7.0]
  def change
    create_table :__ef_migrations_history, id: :uuid do |t|
      t.string :product_version, null: false
    end
  end
end
