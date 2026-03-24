class CreateManagementFees < ActiveRecord::Migration[7.0]
  def change
    create_table :management_fees, id: :uuid do |t|
      t.integer :from_year, null: false
      t.integer :to_year, null: false
      t.decimal :fee_percent, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :management_fees, [:created_by_id]
    # add_index :management_fees, [:updated_by_id]
  end
end
