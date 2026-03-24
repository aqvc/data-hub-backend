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

  enum :legal_status, {
    corporation: "corporation",
    llc: "llc",
    non_profit: "non_profit",
    other: "other",
    partnership: "partnership",
    sole_proprietorship: "sole_proprietorship"
  }, prefix: true
  enum :sector, {
    ad_tech: "ad_tech",
    aerospace: "aerospace",
    ag_tech: "ag_tech",
    agnostic: "agnostic",
    artificial_intelligence: "artificial_intelligence",
    arvr: "arvr",
    auto_tech: "auto_tech",
    b2b_enterprise_saa_s: "b2b_enterprise_saa_s",
    b2b_payments: "b2b_payments",
    big_data: "big_data",
    bio_tech: "bio_tech",
    blockchain_and_web3: "blockchain_and_web3",
    climate_tech: "climate_tech",
    consumer_tech: "consumer_tech",
    cybersecurity: "cybersecurity",
    deep_tech: "deep_tech",
    defence_tech: "defence_tech",
    digital_health: "digital_health",
    ed_tech: "ed_tech",
    energy_tech: "energy_tech",
    environment: "environment",
    fem_tech: "fem_tech",
    fin_tech: "fin_tech",
    food_tech: "food_tech",
    gaming: "gaming",
    health_tech: "health_tech",
    hospitality_tech: "hospitality_tech",
    hr_tech: "hr_tech",
    impact_investing: "impact_investing",
    industrial_tech: "industrial_tech",
    infrastructure_software: "infrastructure_software",
    insure_tech: "insure_tech",
    internet_of_things: "internet_of_things",
    legal_tech: "legal_tech",
    life_sciences: "life_sciences",
    logistics_tech: "logistics_tech",
    manufacturing: "manufacturing",
    maritime_and_defense: "maritime_and_defense",
    maritime_and_defense_tech: "maritime_and_defense_tech",
    marketing_tech: "marketing_tech",
    marketplaces: "marketplaces",
    mobile: "mobile",
    mobility_tech: "mobility_tech",
    oil_gas_and_mining: "oil_gas_and_mining",
    open_source_software: "open_source_software",
    other: "other",
    process_automation: "process_automation",
    prop_tech: "prop_tech",
    retail: "retail",
    robotics: "robotics",
    saa_s: "saa_s",
    software_as_a_service: "software_as_a_service",
    space_tech: "space_tech",
    sports_tech: "sports_tech",
    technology_media_and_telecommunications: "technology_media_and_telecommunications",
    transportation_and_logistics_tech: "transportation_and_logistics_tech",
    travel_and_hospitality_tech: "travel_and_hospitality_tech"
  }, prefix: true
  enum :type, {
    company: "company",
    fund: "fund",
    other: "other"
  }, prefix: true

end
