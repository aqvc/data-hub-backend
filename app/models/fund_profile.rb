class FundProfile < ApplicationRecord

  self.inheritance_column = :_type_disabled

  belongs_to :fund_manager, class_name: "InvestorContact", foreign_key: :fund_manager_id
  belongs_to :organization_profile
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :ideal_investor_profiles
  has_many :investment_vehicles
  has_many :prospect_jobs

  enum :type, {
    corporate: "corporate",
    fund_of_funds: "fund_of_funds",
    growth_equity: "growth_equity",
    life_sciences: "life_sciences",
    other: "other",
    private_equity: "private_equity",
    renewables: "renewables",
    venture_capital: "venture_capital"
  }, prefix: true
  enum :maturity, {
    developing: "developing",
    emerging: "emerging",
    established: "established"
  }
  enum :fund_structure, {
    gp: "gp",
    holding_company: "holding_company",
    lp: "lp"
  }

  SECTOR_FOCUS_VALUES = %w[
    ad_tech aerospace ag_tech agnostic artificial_intelligence arvr auto_tech
    b2b_enterprise_saa_s b2b_payments big_data bio_tech blockchain_and_web3 climate_tech
    consumer_tech cybersecurity deep_tech defence_tech digital_health ed_tech energy_tech
    environment fem_tech fin_tech food_tech gaming health_tech hospitality_tech hr_tech
    impact_investing industrial_tech infrastructure_software insure_tech internet_of_things
    legal_tech life_sciences logistics_tech manufacturing maritime_and_defense
    maritime_and_defense_tech marketing_tech marketplaces mobile mobility_tech
    oil_gas_and_mining open_source_software other process_automation prop_tech retail
    robotics saa_s software_as_a_service space_tech sports_tech
    technology_media_and_telecommunications transportation_and_logistics_tech
    travel_and_hospitality_tech
  ].freeze
  STAGE_FOCUS_VALUES = %w[
    pre_seed seed series_a series_b series_c series_c_plus
  ].freeze
  GEOGRAPHY_FOCUS_VALUES = %w[
    asia australia europe global middle_east north_america pacific south_america
  ].freeze
end
