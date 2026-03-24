class CreateSimilarFundsAndCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :similar_funds_and_companies, id: :uuid do |t|
      t.string :name, null: false
      t.string :website, null: false
      t.string :logo_url
    end
    # add_index :similar_funds_and_companies, [:name, :website], unique: true
    # add_index :similar_funds_and_companies, [:website]
  end
end
