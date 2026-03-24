class CreateIipProspectInvestorContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :iip_prospect_investor_contacts, id: false do |t|
      t.string :investor_contact_id, null: false
      t.string :iip_prospects_id, null: false
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
    end
    # add_index :iip_prospect_investor_contacts, [:created_by_id]
    # add_index :iip_prospect_investor_contacts, [:iip_prospects_id]
    # add_index :iip_prospect_investor_contacts, [:updated_by_id]
  end
end
