class CreateOrganizationMarketingDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :organization_marketing_details, id: :uuid, primary_key: :organization_profile_id do |t|
      t.string :fund_closing_timeframe
      t.string :cold_lp_marketing_openness
      t.string :lp_marketing_budget
      t.string :fte_focus_on_lp_marketing_number
      t.string :weekly_lp_leads_number
      t.string :organization_creator_role
      t.string :interests, null: false, array: true
    end
  end
end
