class Region < ApplicationRecord

  self.table_name = "public.regions"

  has_many :countries
  has_many :ideal_investor_profile_region_focus, class_name: "IdealInvestorProfileRegionFocu", foreign_key: :region_id
  has_many :ideal_investor_profiles, class_name: "IdealInvestorProfile", foreign_key: :region_headquarter_id
  has_many :investment_strategies, class_name: "InvestmentStrategy", foreign_key: :region_headquarter_id
  has_many :investment_strategy_region_focus, class_name: "InvestmentStrategyRegionFocu", foreign_key: :region_id

end
