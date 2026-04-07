class AddInternalDescriptionToInvestors < ActiveRecord::Migration[7.0]
  def change
    add_column :investors, :internal_description, :text
  end
end
