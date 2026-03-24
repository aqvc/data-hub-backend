class CreateInvestorContactsRelated < ActiveRecord::Migration[7.0]
  def change
    create_table :investor_contacts_related, id: :uuid do |t|
      t.string :contact_id, null: false
      t.string :related_contact_id, null: false
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :investor_contacts_related, [:contact_id]
    # add_index :investor_contacts_related, [:created_by_id]
    # add_index :investor_contacts_related, [:related_contact_id]
    # add_index :investor_contacts_related, [:updated_by_id]
  end
end
