class CreateUserTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :user_tokens, id: false do |t|
      t.string :user_id, null: false
      t.text :login_provider, null: false
      t.text :name, null: false
      t.text :value
    end
  end
end
