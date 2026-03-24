class CreateOrganizationProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :organization_profiles, id: :uuid do |t|
      t.string :subdomain, null: false
      t.text :cs_manager_id
      t.text :sales_manager_id
      t.text :account_manager_id
      t.text :crm_record_id
      t.string :company_name, null: false
      t.string :company_legal_name, null: false
      t.integer :company_size_fte
      t.text :website_url
      t.string :billing_contact_id
      t.text :billing_email
      t.text :billing_phone
      t.string :billing_address_id
      t.datetime :fiscal_year_start
      t.string :organization_status, null: false, default: "active"
      t.string :logo_key
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
      t.string :user_id
    end
    # add_index :organization_profiles, [:company_legal_name], unique: true
    # add_index :organization_profiles, [:company_name], unique: true
    # add_index :organization_profiles, [:created_by_id]
    # add_index :organization_profiles, [:subdomain], unique: true
    # add_index :organization_profiles, [:updated_by_id]
    # add_index :organization_profiles, [:user_id]
  end
end
