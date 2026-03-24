class InvestmentStrategyCountryFocus < ApplicationRecord

  self.table_name = "public.investment_strategy_country_focus"

  belongs_to :investment_strategy
  belongs_to :country

end
