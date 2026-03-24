class CreateUserRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :user_refresh_tokens, id: :uuid do |t|
      t.string :token, null: false
      t.string :user_id, null: false
      t.datetime :expires_on_utc, null: false
    end
    # add_index :user_refresh_tokens, [:token], unique: true
    # add_index :user_refresh_tokens, [:user_id]
  end
end
