class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.string :user_name
      t.string :normalized_user_name
      t.string :email
      t.string :normalized_email
      t.boolean :email_confirmed, null: false
      t.text :password_hash
      t.text :security_stamp
      t.text :concurrency_stamp
      t.text :phone_number
      t.boolean :phone_number_confirmed, null: false
      t.boolean :two_factor_enabled, null: false
      t.datetime :lockout_end
      t.boolean :lockout_enabled, null: false
      t.integer :access_failed_count, null: false
    end
    # add_index :users, [:created_by_id]
    # add_index :users, [:normalized_email]
    # add_index :users, [:normalized_user_name], unique: true
    # add_index :users, [:updated_by_id]
  end
end
