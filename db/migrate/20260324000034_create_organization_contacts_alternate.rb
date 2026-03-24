class CreateOrganizationContactsAlternate < ActiveRecord::Migration[7.0]
  def change
    create_table :organization_contacts_alternate, id: :uuid do |t|
      t.string :contact_id, null: false
      t.string :alternate_contact_id, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :organization_contacts_alternate, [:alternate_contact_id]
    # add_index :organization_contacts_alternate, [:contact_id]
    # add_index :organization_contacts_alternate, [:created_by_id]
    # add_index :organization_contacts_alternate, [:updated_by_id]
  end
end
