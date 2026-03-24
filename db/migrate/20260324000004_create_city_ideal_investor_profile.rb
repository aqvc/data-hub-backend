class CreateCityIdealInvestorProfile < ActiveRecord::Migration[7.0]
  def change
    create_table :city_ideal_investor_profile, id: false do |t|
      t.string :ideal_investor_profiles_id, null: false
      t.string :investor_headquarters_id, null: false
    end
    # add_index :city_ideal_investor_profile, [:investor_headquarters_id]
  end
end
