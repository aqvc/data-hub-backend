class CreateUserClaims < ActiveRecord::Migration[7.0]
  def change
    create_table :user_claims, id: :integer do |t|
      t.string :user_id, null: false
      t.text :claim_type
      t.text :claim_value
    end
    # add_index :user_claims, [:user_id]
  end
end
