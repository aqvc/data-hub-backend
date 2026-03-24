class CreateInvestorCurrencies < ActiveRecord::Migration[7.0]
  def change
    create_table :investor_currencies, id: false do |t|
      t.string :investor_id, null: false
      t.string :currency_id, null: false
    end
    # add_index :investor_currencies, [:currency_id]
  end
end
