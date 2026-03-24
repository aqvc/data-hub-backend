class CreateUserDetailsHub < ActiveRecord::Migration[7.0]
  def change
    create_table :user_details_hub, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :user_details_hub, [:created_by_id]
    # add_index :user_details_hub, [:updated_by_id]
  end
end
