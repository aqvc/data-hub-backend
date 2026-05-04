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

  TYPES = %w[balance_sheet fund other].freeze
  FUND_STATUSES = %w[closed open].freeze
  INVESTING_STATUSES = %w[investing not_investing].freeze
  DISTRIBUTION_WATERFALLS = %w[american_waterfall european_waterfall].freeze

  enum :type, TYPES.zip(TYPES).to_h, prefix: true
  enum :fund_status, FUND_STATUSES.zip(FUND_STATUSES).to_h
  enum :investing_status, INVESTING_STATUSES.zip(INVESTING_STATUSES).to_h
  enum :distribution_waterfall, DISTRIBUTION_WATERFALLS.zip(DISTRIBUTION_WATERFALLS).to_h
  enum :jurisdiction, {
    kyc: 0,
    aml: 1,
    audit_approved: 2
  }

end
