class InvestmentEntity < ApplicationRecord

  self.table_name = "public.investment_entities"
  self.inheritance_column = :_type_disabled

  belongs_to :investment_vehicle
  belongs_to :location, class_name: "Location", optional: true
  belongs_to :headquarters_address, class_name: "Location", foreign_key: :headquarters_address_id, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :field_histories
  has_many :investments
  has_many :proof_ledger_comments
  has_many :proof_ledgers

  LEGAL_STATUSES = %w[
    corporation
    llc
    non_profit
    other
    partnership
    sole_proprietorship
  ].freeze

  SECTORS = %w[
    ad_tech
    aerospace
    ag_tech
    agnostic
    artificial_intelligence
    arvr
    auto_tech
    b2b_enterprise_saa_s
    b2b_payments
    big_data
    bio_tech
    blockchain_and_web3
    climate_tech
    consumer_tech
    cybersecurity
    deep_tech
    defence_tech
    digital_health
    ed_tech
    energy_tech
    environment
    fem_tech
    fin_tech
    food_tech
    gaming
    health_tech
    hospitality_tech
    hr_tech
    impact_investing
    industrial_tech
    infrastructure_software
    insure_tech
    internet_of_things
    legal_tech
    life_sciences
    logistics_tech
    manufacturing
    maritime_and_defense
    maritime_and_defense_tech
    marketing_tech
    marketplaces
    mobile
    mobility_tech
    oil_gas_and_mining
    open_source_software
    other
    process_automation
    prop_tech
    retail
    robotics
    saa_s
    software_as_a_service
    space_tech
    sports_tech
    technology_media_and_telecommunications
    transportation_and_logistics_tech
    travel_and_hospitality_tech
  ].freeze

  TYPES = %w[company fund other].freeze

  enum :legal_status, LEGAL_STATUSES.zip(LEGAL_STATUSES).to_h, prefix: true
  enum :sector, SECTORS.zip(SECTORS).to_h, prefix: true
  enum :type, TYPES.zip(TYPES).to_h, prefix: true

end
