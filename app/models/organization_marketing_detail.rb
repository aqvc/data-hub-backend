class OrganizationMarketingDetail < ApplicationRecord

  self.primary_key = :organization_profile_id

  belongs_to :organization_profile, optional: true

  enum :fund_closing_timeframe, {
    beyond: "beyond",
    months1to3: "months1to3",
    months4to12: "months4to12"
  }
  enum :cold_lp_marketing_openness, {
    need_to_learn_more: "need_to_learn_more",
    no: "no",
    yes: "yes"
  }
  enum :lp_marketing_budget, {
    range0to500: "range0to500",
    range2k_to6k: "range2k_to6k",
    range500to2k: "range500to2k",
    range6k_plus: "range6k_plus"
  }
  enum :fte_focus_on_lp_marketing_number, {
    fte0: "fte0",
    fte10plus: "fte10plus",
    fte1to5: "fte1to5",
    fte5to10: "fte5to10"
  }
  enum :weekly_lp_leads_number, {
    leads0to5: "leads0to5",
    leads100plus: "leads100plus",
    leads20to100: "leads20to100",
    leads5to20: "leads5to20"
  }
  enum :organization_creator_role, {
    gp: "gp",
    ir_manager: "ir_manager",
    other: "other"
  }

  INTERESTS_VALUES = %w[
    advise_to_increase_my_cvr_with_lp attend_lp_events_and_investor_dinners
    enhancing_my_fund_brand get_my_pitch_in_front_of_relevant_l_ps
    growing_my_lp_network new_relevant_lp_contacts not_sure_yet
    nurturing_and_campaigning_my_lp_network
  ].freeze
end
