class Country < ApplicationRecord

  self.table_name = "public.countries"

  belongs_to :region
  belongs_to :currency, optional: true
  has_many :cities
  has_many :ideal_investor_profile_country_focuses, class_name: "IdealInvestorProfileCountryFocu", foreign_key: :country_id
  has_many :ideal_investor_profiles, class_name: "IdealInvestorProfile", foreign_key: :country_headquarter_id
  has_many :investment_strategies, class_name: "InvestmentStrategy", foreign_key: :country_headquarter_id
  has_many :investment_strategy_country_focuses, class_name: "InvestmentStrategyCountryFocu", foreign_key: :country_id
  has_many :locations

end
