class CreateInvestorContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :investor_contacts, id: :uuid do |t|
      t.string :investor_id, null: false
      t.text :first_name
      t.text :last_name
      t.text :email
      t.text :alternative_email
      t.datetime :date_of_birth
      t.text :phone
      t.text :source
      t.text :role
      t.string :preferred_contact_method
      t.text :blurb
      t.text :time_zone
      t.text :linked_in_id
      t.text :twitter_handle
      t.datetime :last_contacted_at
      t.datetime :next_followup_at
      t.string :location_id
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :investor_contacts, [:created_by_id]
    # add_index :investor_contacts, [:investor_id]
    # add_index :investor_contacts, [:location_id]
    # add_index :investor_contacts, [:updated_by_id]
  end
end
