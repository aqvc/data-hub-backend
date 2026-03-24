class InvestmentStrategyRegionFocus < ApplicationRecord

  self.table_name = "public.investment_strategy_region_focus"

  belongs_to :investment_strategy
  belongs_to :region

end
