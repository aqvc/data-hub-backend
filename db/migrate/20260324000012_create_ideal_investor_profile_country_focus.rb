class CreateIdealInvestorProfileCountryFocus < ActiveRecord::Migration[7.0]
  def change
    create_table :ideal_investor_profile_country_focus, id: false do |t|
      t.string :ideal_investor_profile_id, null: false
      t.string :country_id, null: false
    end
    # add_index :ideal_investor_profile_country_focus, [:country_id]
  end
end
