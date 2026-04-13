class AddDeviseInvitableToUsers < ActiveRecord::Migration[7.0]
  def up
    change_table :users do |t|
      t.string :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer :invitation_limit
      t.references :invited_by, type: :uuid, polymorphic: true
      t.integer :invitations_count, default: 0
    end

    add_index :users, :invitation_token, unique: true
    add_index :users, :invited_by_id

    # Allow invited users to set password later (skip Devise's password presence validation)
    change_column_null :users, :encrypted_password, true
    change_column_default :users, :encrypted_password, from: "", to: nil
  end

  def down
    change_column_default :users, :encrypted_password, from: nil, to: ""
    change_column_null :users, :encrypted_password, false

    remove_index :users, :invited_by_id
    remove_index :users, :invitation_token

    remove_columns :users,
      :invitation_token,
      :invitation_created_at,
      :invitation_sent_at,
      :invitation_accepted_at,
      :invitation_limit,
      :invited_by_id,
      :invited_by_type,
      :invitations_count
  end
end
