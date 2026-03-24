class CreateSimilarFundAndCompanyIips < ActiveRecord::Migration[7.0]
  def change
    create_table :similar_fund_and_company_iips, id: false do |t|
      t.string :ideal_investor_profile_id, null: false
      t.string :similar_fund_and_company_id, null: false
    end
    # add_index :similar_fund_and_company_iips, [:ideal_investor_profile_id]
  end
end
