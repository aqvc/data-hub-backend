class AddSourceToInvestors < ActiveRecord::Migration[7.0]
  def change
    add_column :investors, :source, :text
  end
end
