class AddDeletedAtForInvestorSoftDelete < ActiveRecord::Migration[7.0]
  TABLES = %i[
    investors
    investment_strategies
    investor_contacts
    events
    field_history
    investor_currencies
    proof_ledgers
    proof_ledger_comments
  ].freeze

  def change
    TABLES.each do |table|
      add_column table, :deleted_at, :datetime
      add_index table, :deleted_at
    end
  end
end
