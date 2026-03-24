class IdealInvestorProfileSuggestion < ApplicationRecord

  enum :targeting_approach, {
    inbound: "inbound",
    outbound: "outbound"
  }

  INVESTOR_TYPE_VALUES = IdealInvestorProfile::INVESTOR_TYPE_VALUES
  ASSET_CLASS_VALUES = IdealInvestorProfile::ASSET_CLASS_VALUES
  MATURITY_FOCUS_VALUES = IdealInvestorProfile::MATURITY_FOCUS_VALUES
  SECTOR_FOCUS_VALUES = FundProfile::SECTOR_FOCUS_VALUES
  STAGE_FOCUS_VALUES = FundProfile::STAGE_FOCUS_VALUES
  STRATEGY_FOCUS_VALUES = IdealInvestorProfile::STRATEGY_FOCUS_VALUES
end
