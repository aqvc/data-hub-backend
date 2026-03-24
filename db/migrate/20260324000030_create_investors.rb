class CreateInvestors < ActiveRecord::Migration[7.0]
  def change
    create_table :investors, id: :uuid do |t|
      t.string :organization_profile_id
      t.string :location_id
      t.string :primary_contact_id
      t.text :name, null: false
      t.string :type
      t.text :legal_name
      t.text :tax_id
      t.text :website_url
      t.text :linked_in_url
      t.text :twitter_url
      t.text :dealroom_url
      t.text :crunchbase_url
      t.decimal :aum_aprox_in_currency
      t.decimal :aum_aprox_in_usd
      t.decimal :dry_powder_approx
      t.decimal :dry_powder_approx_in_usd
      t.text :blurb
      t.text :focus_sectors, null: false, default: [], array: true
      t.text :email_domain
      t.datetime :established_date
      t.text :description
      t.text :logo_url
      t.text :favicon_url
      t.text :aqvc_url
      t.text :wizard_id
      t.integer :year_founded
      t.boolean :qualified, null: false
      t.datetime :qualified_at_utc
      t.string :qualified_by_id
      t.datetime :created_at_utc, null: false
      t.datetime :updated_at_utc
      t.string :created_by_id, null: false
      t.string :updated_by_id
    end
    # add_index :investors, [:created_by_id]
    # add_index :investors, [:location_id]
    # add_index :investors, [:name]
    # add_index :investors, [:organization_profile_id]
    # add_index :investors, [:primary_contact_id]
    # add_index :investors, [:qualified_by_id]
    # add_index :investors, [:updated_by_id]
  end
end
