class CreateRoleClaims < ActiveRecord::Migration[7.0]
  def change
    create_table :role_claims, id: :integer do |t|
      t.string :role_id, null: false
      t.text :claim_type
      t.text :claim_value
    end
    # add_index :role_claims, [:role_id]
  end
end
