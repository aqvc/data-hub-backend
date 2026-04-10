class OrganizationContact < ApplicationRecord

  belongs_to :investor_contact_reference, class_name: "InvestorContact", foreign_key: :investor_contact_reference_id
  belongs_to :organization_profile
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
  belongs_to :owner, class_name: "User", foreign_key: :owner_id
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :activities
  has_many :engagements
  has_many :iip_prospects
  has_many :alternate_contact_links, class_name: "OrganizationContactsAlternate", foreign_key: :contact_id
  has_many :inverse_alternate_contact_links, class_name: "OrganizationContactsAlternate", foreign_key: :alternate_contact_id

  enum :skills, {
    asset_allocation: "asset_allocation",
    co_investments: "co_investments",
    cross_border_investments: "cross_border_investments",
    data_driven_sourcing: "data_driven_sourcing",
    direct_investments: "direct_investments",
    due_diligence: "due_diligence",
    emerging_managers: "emerging_managers",
    esg_and_impact_assessment: "esg_and_impact_assessment",
    fund_of_funds: "fund_of_funds",
    fund_structuring: "fund_structuring",
    legal_and_compliance: "legal_and_compliance",
    lp_reporting_standards: "lp_reporting_standards",
    lp_syndication: "lp_syndication",
    portfolio_construction: "portfolio_construction",
    private_equity: "private_equity",
    quantitative_analysis: "quantitative_analysis",
    risk_management: "risk_management",
    secondaries: "secondaries",
    thematic_investing: "thematic_investing",
    venture_debt: "venture_debt"
  }
  enum :preferred_contact_method, {
    email: "email",
    in_person: "in_person",
    phone: "phone",
    social_media: "social_media",
    video_call: "video_call"
  }
  enum :pipeline_status, {
    initiated: "initiated",
    new_organization_contact: "new_organization_contact",
    nurturing: "nurturing",
    soft_commit: "soft_commit",
    unknown: "unknown"
  }
  enum :cadence, {
    high: "high",
    low: "low",
    medium: "medium"
  }
  enum :relationship, {
    following: "following",
    no_relationship: "no_relationship",
    unfollowed: "unfollowed"
  }

end
