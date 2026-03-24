class CreateOrganizationContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :organization_contacts, id: :uuid do |t|
      t.string :organization_profile_id, null: false
      t.string :investor_contact_reference_id, null: false
      t.text :first_name, null: false
      t.text :last_name, null: false
      t.text :email, null: false
      t.text :crm_link
      t.text :phone
      t.text :bio
      t.text :source, null: false
      t.text :notes
      t.text :group, default: "{}"
      t.string :skills
      t.text :tags, null: false, default: [], array: true
      t.text :groups, null: false, array: true
      t.text :related_contacts
      t.text :potential_introducers
      t.text :title
      t.string :preferred_contact_method
      t.text :potential_ticket_size
      t.text :linked_in_id
      t.text :twitter_handle
      t.decimal :conviction
      t.string :pipeline_status, null: false
      t.string :owner_id, null: false
      t.string :cadence
      t.string :relationship, null: false
      t.datetime :last_contacted_at
      t.datetime :next_followup_at
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :organization_contacts, [:created_by_id]
    # add_index :organization_contacts, [:investor_contact_reference_id]
    # add_index :organization_contacts, [:organization_profile_id]
    # add_index :organization_contacts, [:owner_id]
    # add_index :organization_contacts, [:updated_by_id]
  end
end
