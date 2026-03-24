class CreateIdealInvestorProfileSuggestions < ActiveRecord::Migration[7.0]
  def change
    create_table :ideal_investor_profile_suggestions, id: :uuid do |t|
      t.string :name, null: false
      t.string :description
      t.string :briefing
      t.boolean :is_active, null: false, default: true
      t.decimal :min_check_size, precision: 18, scale: 2
      t.decimal :max_check_size, precision: 18, scale: 2
      t.text :thematic_keywords, array: true
      t.string :investor_type, array: true
      t.string :asset_class, null: false, array: true
      t.string :maturity_focus, array: true
      t.string :sector_focus, null: false, array: true
      t.string :stage_focus, array: true
      t.string :strategy_focus, array: true
      t.string :targeting_approach
    end
    # add_index :ideal_investor_profile_suggestions, [:name]
  end
end
