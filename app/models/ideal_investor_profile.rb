class IdealInvestorProfile < ApplicationRecord

  self.table_name = "public.ideal_investor_profiles"

  belongs_to :country_headquarter, class_name: "Country", foreign_key: :country_headquarter_id, optional: true
  belongs_to :fund_profile, optional: true
  belongs_to :organization_profile
  belongs_to :region_headquarter, class_name: "Region", foreign_key: :region_headquarter_id, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :city_ideal_investor_profiles, class_name: "CityIdealInvestorProfile", foreign_key: :ideal_investor_profiles_id
  has_many :ideal_investor_profile_country_focus, class_name: "IdealInvestorProfileCountryFocu", foreign_key: :ideal_investor_profile_id
  has_many :ideal_investor_profile_prospect_jobs
  has_many :ideal_investor_profile_region_focus, class_name: "IdealInvestorProfileRegionFocu", foreign_key: :ideal_investor_profile_id
  has_many :similar_fund_and_company_iips, class_name: "SimilarFundAndCompanyIip", foreign_key: :ideal_investor_profile_id

  IIP_STATUSES = %w[active active_in_use archived].freeze
  TARGETING_APPROACHES = %w[inbound outbound].freeze

  enum :iip_status, IIP_STATUSES.zip(IIP_STATUSES).to_h
  enum :targeting_approach, TARGETING_APPROACHES.zip(TARGETING_APPROACHES).to_h

  ASSET_CLASS_VALUES = %w[
    agriculture art_and_antiques buyout crypto debt_general debt_special_situations
    direct_distressed direct_pe direct_restructuring direct_vc fixed_income
    fund_of_funds_general fund_of_funds_pe fund_of_funds_vc funds_general funds_vc
    hedge_fund infrastructure ip_rights mezzanine other public_stocks real_estate
    real_estate_debt
  ].freeze
  SECTOR_FOCUS_VALUES = FundProfile::SECTOR_FOCUS_VALUES
  INVESTOR_TYPE_VALUES = %w[
    asset_manager bank corporate endowment exchanges family_office fund_of_funds
    government hnwi hnwi_1_5 hnwi_30plus hnwi_5_30 institutional_investor insurance
    multi_family_office other pension_fund religious sovereign_wealth_fund technology
    union utility_provider
  ].freeze
  MATURITY_FOCUS_VALUES = %w[developing emerging established].freeze
  STAGE_FOCUS_VALUES = FundProfile::STAGE_FOCUS_VALUES
  STRATEGY_FOCUS_VALUES = %w[primary secondary].freeze
end
