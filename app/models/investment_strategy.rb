class InvestmentStrategy < ApplicationRecord

  acts_as_paranoid

  self.table_name = "public.investment_strategies"

  belongs_to :investor, class_name: "Investor", optional: true
  belongs_to :investor_contact, class_name: "InvestorContact", optional: true
  belongs_to :country_headquarter, class_name: "Country", foreign_key: :country_headquarter_id, optional: true
  belongs_to :region_headquarter, class_name: "Region", foreign_key: :region_headquarter_id, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :investment_strategy_region_focuses,
           class_name: "InvestmentStrategyRegionFocus",
           foreign_key: :investment_strategy_id,
           dependent: nil
  has_many :investment_strategy_country_focuses,
           class_name: "InvestmentStrategyCountryFocus",
           foreign_key: :investment_strategy_id,
           dependent: nil
  has_many :field_histories
  has_many :investment_vehicles_investment_strategies, class_name: "InvestmentVehicleInvestmentStrategy"
  has_many :investments
  has_many :proof_ledger_comments
  has_many :proof_ledgers

  enum :business_type, {
    b2b: "b2b",
    b2b2c: "b2b2c",
    b2c: "b2c",
    b2g: "b2g",
    d2c: "d2c",
    g2b: "g2b"
  }
  enum :revenue_type, {
    per_transaction: "per_transaction",
    retail: "retail",
    saa_s: "saa_s",
    service: "service",
    subscription: "subscription"
  }
  enum :founder_type, {
    female_founder: "female_founder",
    first_timer: "first_timer",
    scientist: "scientist",
    serial_entrepreneurs: "serial_entrepreneurs"
  }
  enum :asset_type, {
    brand: "brand",
    community: "community",
    customer_base: "customer_base",
    infrastructure: "infrastructure",
    patent: "patent",
    tech: "tech"
  }

  INVESTOR_TYPE_FOCUS_VALUES = IdealInvestorProfile::INVESTOR_TYPE_VALUES
  SECTOR_INVESTMENT_FOCUS_VALUES = FundProfile::SECTOR_FOCUS_VALUES
  MATURITY_FOCUS_VALUES = IdealInvestorProfile::MATURITY_FOCUS_VALUES
  STAGE_FOCUS_VALUES = FundProfile::STAGE_FOCUS_VALUES
  ASSET_CLASS_FOCUS_VALUES = IdealInvestorProfile::ASSET_CLASS_VALUES
  STRATEGY_FOCUS_VALUES = IdealInvestorProfile::STRATEGY_FOCUS_VALUES
end
