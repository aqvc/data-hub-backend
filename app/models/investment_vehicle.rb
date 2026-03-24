class InvestmentVehicle < ApplicationRecord

  self.table_name = "public.investment_vehicles"
  self.inheritance_column = :_type_disabled

  belongs_to :investor
  belongs_to :currency, optional: true
  belongs_to :fund_profile, optional: true
  belongs_to :key_person, class_name: "InvestorContact", foreign_key: :key_person_id, optional: true
  belongs_to :marketing_geographies, class_name: "Location", foreign_key: :marketing_geographies_id, optional: true
  belongs_to :location, optional: true
  belongs_to :management_fee, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :investment_entities
  has_many :investment_vehicle_investment_strategies,
           class_name: "InvestmentVehicleInvestmentStrategy",
           foreign_key: :investment_vehicle_id,
           dependent: nil
  has_many :field_histories
  has_many :iip_prospects
  has_many :investment_vehicle_key_contacts
  has_many :investment_vehicles_investment_strategies, class_name: "InvestmentVehicleInvestmentStrategy"
  has_many :investments
  has_many :proof_ledger_comments
  has_many :proof_ledgers

  enum :type, {
    balance_sheet: "balance_sheet",
    fund: "fund",
    other: "other"
  }, prefix: true
  enum :fund_status, {
    closed: "closed",
    open: "open"
  }
  enum :investing_status, {
    investing: "investing",
    not_investing: "not_investing"
  }
  enum :distribution_waterfall, {
    american_waterfall: "american_waterfall",
    european_waterfall: "european_waterfall"
  }

end
