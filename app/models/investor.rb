class Investor < ApplicationRecord

  self.table_name = "public.investors"
  self.inheritance_column = :_type_disabled

  belongs_to :location, optional: true
  belongs_to :primary_contact, class_name: "InvestorContact", foreign_key: :primary_contact_id, optional: true
  belongs_to :organization_profile, optional: true
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :qualified_by, class_name: "User", foreign_key: :qualified_by_id, optional: true
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :investment_vehicles
  has_many :investment_strategies
  has_many :investor_contacts
  has_many :events
  has_many :field_histories
  has_many :investor_currencies
  has_many :proof_ledger_comments
  has_many :proof_ledgers

  enum :type, {
    asset_manager: "asset_manager",
    bank: "bank",
    corporate: "corporate",
    endowment: "endowment",
    exchanges: "exchanges",
    family_office: "family_office",
    fund_of_funds: "fund_of_funds",
    government: "government",
    hnwi: "hnwi",
    hnwi_1_5: "hnwi_1_5",
    hnwi_30plus: "hnwi_30plus",
    hnwi_5_30: "hnwi_5_30",
    institutional_investor: "institutional_investor",
    insurance: "insurance",
    multi_family_office: "multi_family_office",
    other: "other",
    pension_fund: "pension_fund",
    religious: "religious",
    sovereign_wealth_fund: "sovereign_wealth_fund",
    technology: "technology",
    union: "union",
    utility_provider: "utility_provider"
  }, prefix: true

end
