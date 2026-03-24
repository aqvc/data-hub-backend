class Investment < ApplicationRecord

  belongs_to :investment_entity
  belongs_to :investment_strategy, optional: true
  belongs_to :investment_vehicle
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

  enum :asset_class, {
    agriculture: "agriculture",
    art_and_antiques: "art_and_antiques",
    buyout: "buyout",
    crypto: "crypto",
    debt_general: "debt_general",
    debt_special_situations: "debt_special_situations",
    direct_distressed: "direct_distressed",
    direct_pe: "direct_pe",
    direct_restructuring: "direct_restructuring",
    direct_vc: "direct_vc",
    fixed_income: "fixed_income",
    fund_of_funds_general: "fund_of_funds_general",
    fund_of_funds_pe: "fund_of_funds_pe",
    fund_of_funds_vc: "fund_of_funds_vc",
    funds_general: "funds_general",
    funds_vc: "funds_vc",
    hedge_fund: "hedge_fund",
    infrastructure: "infrastructure",
    ip_rights: "ip_rights",
    mezzanine: "mezzanine",
    other: "other",
    public_stocks: "public_stocks",
    real_estate: "real_estate",
    real_estate_debt: "real_estate_debt"
  }
  enum :status, {
    active: "active",
    exit: "exit",
    not_available: "not_available",
    partial_exit: "partial_exit"
  }, prefix: true

end
