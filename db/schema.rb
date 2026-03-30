# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_03_30_000056) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "activity_status", ["cancelled", "completed", "in_progress", "pending"]
  create_enum "activity_type", ["added_as_follower", "added_to_campaign", "call", "email_sent", "exported", "invited_to_event", "linked_in_connection_sent", "profile_shared", "system_notification", "wizard_sent"]
  create_enum "asset_class", ["agriculture", "art_and_antiques", "buyout", "crypto", "debt_general", "debt_special_situations", "direct_distressed", "direct_pe", "direct_restructuring", "direct_vc", "fixed_income", "fund_of_funds_general", "fund_of_funds_pe", "fund_of_funds_vc", "funds_general", "funds_vc", "hedge_fund", "infrastructure", "ip_rights", "mezzanine", "other", "public_stocks", "real_estate", "real_estate_debt"]
  create_enum "asset_type", ["brand", "community", "customer_base", "infrastructure", "patent", "tech"]
  create_enum "business_type", ["b2b", "b2b2c", "b2c", "b2g", "d2c", "g2b"]
  create_enum "cadence", ["high", "low", "medium"]
  create_enum "cold_lp_marketing_openness", ["need_to_learn_more", "no", "yes"]
  create_enum "contact_skill", ["asset_allocation", "co_investments", "cross_border_investments", "data_driven_sourcing", "direct_investments", "due_diligence", "emerging_managers", "esg_and_impact_assessment", "fund_of_funds", "fund_structuring", "legal_and_compliance", "lp_reporting_standards", "lp_syndication", "portfolio_construction", "private_equity", "quantitative_analysis", "risk_management", "secondaries", "thematic_investing", "venture_debt"]
  create_enum "distribution_waterfall", ["american_waterfall", "european_waterfall"]
  create_enum "engagement_status", ["cancelled", "completed", "in_progress", "pending"]
  create_enum "engagement_type", ["attended_event", "meeting_scheduled", "message_reply", "opened_email", "replied_to_email", "soft_commitment_clicked", "soft_commitment_saved", "viewed_profile"]
  create_enum "founder_type", ["female_founder", "first_timer", "scientist", "serial_entrepreneurs"]
  create_enum "fte_focus_on_lp_marketing_number", ["fte0", "fte10plus", "fte1to5", "fte5to10"]
  create_enum "fund_closing_timeframe", ["beyond", "months1to3", "months4to12"]
  create_enum "fund_status", ["closed", "open"]
  create_enum "fund_structure", ["gp", "holding_company", "lp"]
  create_enum "fund_type", ["corporate", "fund_of_funds", "growth_equity", "life_sciences", "other", "private_equity", "renewables", "venture_capital"]
  create_enum "geography", ["asia", "australia", "europe", "global", "middle_east", "north_america", "pacific", "south_america"]
  create_enum "iip_status", ["active", "active_in_use", "archived"]
  create_enum "investing_status", ["investing", "not_investing"]
  create_enum "investment_entity_type", ["company", "fund", "other"]
  create_enum "investment_status", ["active", "exit", "not_available", "partial_exit"]
  create_enum "investment_vehicle_type", ["balance_sheet", "fund", "other"]
  create_enum "investor_type", ["asset_manager", "bank", "corporate", "endowment", "exchanges", "family_office", "fund_of_funds", "government", "hnwi", "hnwi_1_5", "hnwi_30plus", "hnwi_5_30", "institutional_investor", "insurance", "multi_family_office", "other", "pension_fund", "religious", "sovereign_wealth_fund", "technology", "union", "utility_provider"]
  create_enum "legal_status", ["corporation", "llc", "non_profit", "other", "partnership", "sole_proprietorship"]
  create_enum "location_type", ["primary", "secondary"]
  create_enum "lp_marketing_budget", ["range0to500", "range2k_to6k", "range500to2k", "range6k_plus"]
  create_enum "maturity", ["developing", "emerging", "established"]
  create_enum "organization_creator_role", ["gp", "ir_manager", "other"]
  create_enum "organization_interests", ["advise_to_increase_my_cvr_with_lp", "attend_lp_events_and_investor_dinners", "enhancing_my_fund_brand", "get_my_pitch_in_front_of_relevant_l_ps", "growing_my_lp_network", "new_relevant_lp_contacts", "not_sure_yet", "nurturing_and_campaigning_my_lp_network"]
  create_enum "organization_member_type", ["admin", "member", "owner"]
  create_enum "organization_status", ["active", "inactive"]
  create_enum "pipeline_status", ["initiated", "new", "nurturing", "soft_commit", "unknown"]
  create_enum "preferred_contact_method", ["email", "in_person", "phone", "social_media", "video_call"]
  create_enum "proof_status", ["active", "pending", "rejected"]
  create_enum "proof_type", ["ai_research", "email", "list", "manual", "meeting", "news", "provider", "proxy", "transcript", "website", "wizard"]
  create_enum "prospect_job_status", ["cancelled", "completed", "in_progress", "not_started", "on_hold"]
  create_enum "prospect_priority", ["critical", "high", "low", "medium"]
  create_enum "prospect_status", ["approved", "pending", "rejected"]
  create_enum "relationship_status", ["following", "no_relationship", "unfollowed"]
  create_enum "revenue_type", ["per_transaction", "retail", "saa_s", "service", "subscription"]
  create_enum "sector", ["ad_tech", "aerospace", "ag_tech", "agnostic", "artificial_intelligence", "arvr", "auto_tech", "b2b_enterprise_saa_s", "b2b_payments", "big_data", "bio_tech", "blockchain_and_web3", "climate_tech", "consumer_tech", "cybersecurity", "deep_tech", "defence_tech", "digital_health", "ed_tech", "energy_tech", "environment", "fem_tech", "fin_tech", "food_tech", "gaming", "health_tech", "hospitality_tech", "hr_tech", "impact_investing", "industrial_tech", "infrastructure_software", "insure_tech", "internet_of_things", "legal_tech", "life_sciences", "logistics_tech", "manufacturing", "maritime_and_defense", "maritime_and_defense_tech", "marketing_tech", "marketplaces", "mobile", "mobility_tech", "oil_gas_and_mining", "open_source_software", "other", "process_automation", "prop_tech", "retail", "robotics", "saa_s", "software_as_a_service", "space_tech", "sports_tech", "technology_media_and_telecommunications", "transportation_and_logistics_tech", "travel_and_hospitality_tech"]
  create_enum "stage", ["pre_seed", "seed", "series_a", "series_b", "series_c", "series_c_plus"]
  create_enum "strategy", ["primary", "secondary"]
  create_enum "targeting_approach", ["inbound", "outbound"]
  create_enum "weekly_lp_leads_number", ["leads0to5", "leads100plus", "leads20to100", "leads5to20"]

  create_table "__ef_migrations_history", primary_key: "migration_id", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "product_version", limit: 32, null: false
  end

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_contact_id", null: false
    t.text "activity_name", null: false
    t.text "description"
    t.timestamptz "start_time", null: false
    t.timestamptz "end_time"
    t.integer "reference_id"
    t.enum "type", null: false, enum_type: "activity_type"
    t.enum "status", null: false, enum_type: "activity_status"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["created_by_id"], name: "ix_activities_created_by_id"
    t.index ["organization_contact_id"], name: "ix_activities_organization_contact_id"
    t.index ["updated_by_id"], name: "ix_activities_updated_by_id"
  end

  create_table "cities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.uuid "country_id", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["country_id"], name: "ix_cities_country_id"
  end

  create_table "city_ideal_investor_profile", primary_key: ["ideal_investor_profiles_id", "investor_headquarters_id"], force: :cascade do |t|
    t.uuid "ideal_investor_profiles_id", null: false
    t.uuid "investor_headquarters_id", null: false
    t.index ["investor_headquarters_id"], name: "ix_city_ideal_investor_profile_investor_headquarters_id"
  end

  create_table "countries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "region_id", null: false
    t.text "name", null: false
    t.text "iso_code", null: false
    t.text "iso3code", null: false
    t.text "calling_code", null: false
    t.uuid "currency_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["currency_id"], name: "ix_countries_currency_id"
    t.index ["region_id"], name: "ix_countries_region_id"
  end

  create_table "currencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.string "symbol", limit: 10
    t.string "code", limit: 3
    t.integer "decimal_places"
    t.boolean "is_active", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["code"], name: "ix_currencies_code", unique: true
  end

  create_table "engagement", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_contact_id", null: false
    t.text "engagement_name", null: false
    t.timestamptz "engagement_date"
    t.uuid "activity_id"
    t.text "description"
    t.text "sentiment_type"
    t.text "sentiment_context"
    t.integer "reference_id"
    t.enum "type", null: false, enum_type: "engagement_type"
    t.enum "status", null: false, enum_type: "engagement_status"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["activity_id"], name: "ix_engagement_activity_id"
    t.index ["created_by_id"], name: "ix_engagement_created_by_id"
    t.index ["organization_contact_id"], name: "ix_engagement_organization_contact_id"
    t.index ["updated_by_id"], name: "ix_engagement_updated_by_id"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.uuid "investor_id"
    t.index ["investor_id"], name: "ix_events_investor_id"
  end

  create_table "feedback_ledgers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "proof_ledger_id", null: false
    t.uuid "prospect_job_id", null: false
    t.text "criteria_name"
    t.text "criteria_value"
    t.text "proof_text"
    t.text "feedback"
    t.integer "feedback_score"
    t.timestamptz "feedback_date"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_feedback_ledgers_created_by_id"
    t.index ["proof_ledger_id"], name: "ix_feedback_ledgers_proof_ledger_id"
    t.index ["prospect_job_id"], name: "ix_feedback_ledgers_prospect_job_id"
    t.index ["updated_by_id"], name: "ix_feedback_ledgers_updated_by_id"
  end

  create_table "field_history", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "investor_id"
    t.uuid "investment_vehicle_id"
    t.uuid "investment_strategy_id"
    t.uuid "investor_contact_id"
    t.uuid "investment_entity_id"
    t.text "field_id", null: false
    t.text "criteria_name"
    t.text "criteria_value_old"
    t.text "criteria_value_new"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_field_history_created_by_id"
    t.index ["investment_entity_id"], name: "ix_field_history_investment_entity_id"
    t.index ["investment_strategy_id"], name: "ix_field_history_investment_strategy_id"
    t.index ["investment_vehicle_id"], name: "ix_field_history_investment_vehicle_id"
    t.index ["investor_contact_id"], name: "ix_field_history_investor_contact_id"
    t.index ["investor_id"], name: "ix_field_history_investor_id"
    t.index ["updated_by_id"], name: "ix_field_history_updated_by_id"
  end

  create_table "fund_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_profile_id", null: false
    t.uuid "fund_manager_id", null: false
    t.text "fund_name", null: false
    t.enum "type", null: false, enum_type: "fund_type"
    t.enum "sector_focus", null: false, array: true, enum_type: "sector"
    t.enum "stage_focus", null: false, array: true, enum_type: "stage"
    t.enum "geography_focus", null: false, array: true, enum_type: "geography"
    t.text "fund_generation"
    t.decimal "target_fund_size"
    t.integer "vintage_year"
    t.enum "maturity", null: false, enum_type: "maturity"
    t.decimal "min_ticket"
    t.timestamptz "close_date"
    t.timestamptz "launch_date"
    t.enum "fund_structure", null: false, enum_type: "fund_structure"
    t.hstore "fees"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["created_by_id"], name: "ix_fund_profiles_created_by_id"
    t.index ["fund_manager_id"], name: "ix_fund_profiles_fund_manager_id"
    t.index ["organization_profile_id"], name: "ix_fund_profiles_organization_profile_id"
    t.index ["updated_by_id"], name: "ix_fund_profiles_updated_by_id"
  end

  create_table "ideal_investor_profile_country_focus", primary_key: ["ideal_investor_profile_id", "country_id"], force: :cascade do |t|
    t.uuid "ideal_investor_profile_id", null: false
    t.uuid "country_id", null: false
    t.index ["country_id"], name: "ix_ideal_investor_profile_country_focus_country_id"
  end

  create_table "ideal_investor_profile_prospect_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "prospect_job_id", null: false
    t.uuid "ideal_investor_profile_id", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_ideal_investor_profile_prospect_jobs_created_by_id"
    t.index ["ideal_investor_profile_id"], name: "ix_ideal_investor_profile_prospect_jobs_ideal_investor_profile"
    t.index ["prospect_job_id"], name: "ix_ideal_investor_profile_prospect_jobs_prospect_job_id", unique: true
    t.index ["updated_by_id"], name: "ix_ideal_investor_profile_prospect_jobs_updated_by_id"
  end

  create_table "ideal_investor_profile_region_focus", primary_key: ["ideal_investor_profile_id", "region_id"], force: :cascade do |t|
    t.uuid "ideal_investor_profile_id", null: false
    t.uuid "region_id", null: false
    t.index ["region_id"], name: "ix_ideal_investor_profile_region_focus_region_id"
  end

  create_table "ideal_investor_profile_suggestions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "description", limit: 4000
    t.string "briefing", limit: 4000
    t.boolean "is_active", default: true, null: false
    t.decimal "min_check_size", precision: 18, scale: 2
    t.decimal "max_check_size", precision: 18, scale: 2
    t.text "thematic_keywords", array: true
    t.enum "investor_type", array: true, enum_type: "investor_type"
    t.enum "asset_class", null: false, array: true, enum_type: "asset_class"
    t.enum "maturity_focus", array: true, enum_type: "maturity"
    t.enum "sector_focus", null: false, array: true, enum_type: "sector"
    t.enum "stage_focus", array: true, enum_type: "stage"
    t.enum "strategy_focus", array: true, enum_type: "strategy"
    t.enum "targeting_approach", enum_type: "targeting_approach"
    t.index ["name"], name: "ix_ideal_investor_profile_suggestions_name"
  end

  create_table "ideal_investor_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_profile_id", null: false
    t.string "name", limit: 250, null: false
    t.string "description", limit: 4000
    t.enum "iip_status", default: "active", null: false, enum_type: "iip_status"
    t.timestamptz "due_date", null: false
    t.integer "target_nr_of_prospects_to_generate", null: false
    t.enum "asset_class", null: false, array: true, enum_type: "asset_class"
    t.enum "sector_focus", null: false, array: true, enum_type: "sector"
    t.enum "investor_type", array: true, enum_type: "investor_type"
    t.enum "maturity_focus", array: true, enum_type: "maturity"
    t.enum "stage_focus", array: true, enum_type: "stage"
    t.decimal "min_check_size", precision: 18, scale: 2
    t.decimal "max_check_size", precision: 18, scale: 2
    t.enum "targeting_approach", enum_type: "targeting_approach"
    t.text "thematic_keywords", array: true
    t.string "briefing", limit: 4000
    t.uuid "fund_profile_id"
    t.enum "strategy_focus", array: true, enum_type: "strategy"
    t.uuid "region_headquarter_id"
    t.uuid "country_headquarter_id"
    t.text "city_headquarter"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["country_headquarter_id"], name: "ix_ideal_investor_profiles_country_headquarter_id"
    t.index ["created_by_id"], name: "ix_ideal_investor_profiles_created_by_id"
    t.index ["fund_profile_id"], name: "ix_ideal_investor_profiles_fund_profile_id"
    t.index ["name", "organization_profile_id"], name: "ix_ideal_investor_profiles_name_organization_profile_id", unique: true
    t.index ["name"], name: "ix_ideal_investor_profiles_name"
    t.index ["organization_profile_id"], name: "ix_ideal_investor_profiles_organization_profile_id"
    t.index ["region_headquarter_id"], name: "ix_ideal_investor_profiles_region_headquarter_id"
    t.index ["updated_by_id"], name: "ix_ideal_investor_profiles_updated_by_id"
  end

  create_table "iip_prospect_investor_contacts", primary_key: ["investor_contact_id", "iip_prospects_id"], force: :cascade do |t|
    t.uuid "investor_contact_id", null: false
    t.uuid "iip_prospects_id", null: false
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["created_by_id"], name: "ix_iip_prospect_investor_contacts_created_by_id"
    t.index ["iip_prospects_id"], name: "ix_iip_prospect_investor_contacts_iip_prospects_id"
    t.index ["updated_by_id"], name: "ix_iip_prospect_investor_contacts_updated_by_id"
  end

  create_table "iip_prospects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "prospect_job_id", null: false
    t.uuid "investment_vehicle_id", null: false
    t.uuid "organization_contact_id", null: false
    t.enum "status", null: false, enum_type: "prospect_status"
    t.text "rejection_reason"
    t.text "rejection_reason_qa"
    t.text "rejection_reason_qa_code"
    t.text "rejection_reason_code"
    t.decimal "matched_score"
    t.boolean "warm_intro_requested", null: false
    t.text "data_manager_comment"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_iip_prospects_created_by_id"
    t.index ["investment_vehicle_id"], name: "ix_iip_prospects_investment_vehicle_id"
    t.index ["organization_contact_id"], name: "ix_iip_prospects_organization_contact_id"
    t.index ["prospect_job_id"], name: "ix_iip_prospects_prospect_job_id"
    t.index ["updated_by_id"], name: "ix_iip_prospects_updated_by_id"
  end

  create_table "investment_entities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "location_id"
    t.uuid "investment_vehicle_id", null: false
    t.text "name"
    t.text "legal_name"
    t.enum "legal_status", enum_type: "legal_status"
    t.text "website_url"
    t.text "favicon_url"
    t.text "logo_url"
    t.enum "sector", enum_type: "sector"
    t.enum "type", enum_type: "investment_entity_type"
    t.uuid "headquarters_address_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_investment_entities_created_by_id"
    t.index ["headquarters_address_id"], name: "ix_investment_entities_headquarters_address_id"
    t.index ["investment_vehicle_id"], name: "ix_investment_entities_investment_vehicle_id"
    t.index ["location_id"], name: "ix_investment_entities_location_id"
    t.index ["updated_by_id"], name: "ix_investment_entities_updated_by_id"
  end

  create_table "investment_strategies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "investor_id"
    t.uuid "investor_contact_id"
    t.text "name"
    t.decimal "aum"
    t.integer "target_investments"
    t.integer "experience_in_years"
    t.text "program"
    t.enum "investor_type_focus", default: [], null: false, array: true, enum_type: "investor_type"
    t.enum "sector_investment_focus", default: [], null: false, array: true, enum_type: "sector"
    t.enum "maturity_focus", default: [], null: false, array: true, enum_type: "maturity"
    t.enum "stage_focus", default: [], null: false, array: true, enum_type: "stage"
    t.enum "asset_class_focus", default: [], null: false, array: true, enum_type: "asset_class"
    t.decimal "min_check_size"
    t.decimal "max_check_size"
    t.decimal "ideal_check_size"
    t.decimal "min_fund_size"
    t.decimal "max_fund_size"
    t.decimal "revenue_min"
    t.decimal "revenue_max"
    t.decimal "profit_min"
    t.decimal "profit_max"
    t.decimal "valuation_min"
    t.decimal "valuation_max"
    t.decimal "deal_size_min"
    t.decimal "deal_size_max"
    t.integer "min_investment_horizon"
    t.integer "max_investment_horizon"
    t.decimal "irr_min"
    t.decimal "dpi_min"
    t.decimal "tvpi_min"
    t.decimal "moic_min"
    t.decimal "total_capital_raised_min"
    t.decimal "total_capital_raised_max"
    t.enum "business_type", enum_type: "business_type"
    t.enum "revenue_type", enum_type: "revenue_type"
    t.enum "founder_type", enum_type: "founder_type"
    t.enum "asset_type", enum_type: "asset_type"
    t.decimal "target_ownership_min"
    t.decimal "target_ownership_max"
    t.boolean "leading_rounds"
    t.boolean "following_rounds"
    t.boolean "convertible_loans"
    t.boolean "debt"
    t.boolean "re_up_behavior"
    t.decimal "min_founder_stake"
    t.decimal "max_fund_commitment"
    t.boolean "board_seat_requirement"
    t.boolean "board_observer_requirement"
    t.text "things_what_get_us_excited"
    t.text "common_reasons_why_we_pass"
    t.text "how_we_help_investments"
    t.decimal "follow_on_reserve_ratio"
    t.enum "strategy_focus", default: [], null: false, array: true, enum_type: "strategy"
    t.uuid "region_headquarter_id"
    t.uuid "country_headquarter_id"
    t.text "city_headquarter"
    t.text "events_attendance", array: true
    t.text "keywords", array: true
    t.integer "risk_tolerance"
    t.text "esg_preferences", array: true
    t.boolean "esg_sdg_focus"
    t.hstore "geo_targeting"
    t.hstore "score_weightings"
    t.text "note"
    t.timestamptz "last_modified_at"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["country_headquarter_id"], name: "ix_investment_strategies_country_headquarter_id"
    t.index ["created_by_id"], name: "ix_investment_strategies_created_by_id"
    t.index ["investor_contact_id"], name: "ix_investment_strategies_investor_contact_id"
    t.index ["investor_id"], name: "ix_investment_strategies_investor_id"
    t.index ["region_headquarter_id"], name: "ix_investment_strategies_region_headquarter_id"
    t.index ["updated_by_id"], name: "ix_investment_strategies_updated_by_id"
  end

  create_table "investment_strategy_country_focus", primary_key: ["investment_strategy_id", "country_id"], force: :cascade do |t|
    t.uuid "investment_strategy_id", null: false
    t.uuid "country_id", null: false
    t.index ["country_id"], name: "ix_investment_strategy_country_focus_country_id"
  end

  create_table "investment_strategy_region_focus", primary_key: ["investment_strategy_id", "region_id"], force: :cascade do |t|
    t.uuid "investment_strategy_id", null: false
    t.uuid "region_id", null: false
    t.index ["region_id"], name: "ix_investment_strategy_region_focus_region_id"
  end

  create_table "investment_vehicle_key_contacts", primary_key: ["investment_vehicle_id", "investor_contact_id"], force: :cascade do |t|
    t.uuid "investment_vehicle_id", null: false
    t.uuid "investor_contact_id", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_investment_vehicle_key_contacts_created_by_id"
    t.index ["investor_contact_id"], name: "ix_investment_vehicle_key_contacts_investor_contact_id"
    t.index ["updated_by_id"], name: "ix_investment_vehicle_key_contacts_updated_by_id"
  end

  create_table "investment_vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "investor_id", null: false
    t.uuid "currency_id"
    t.uuid "location_id"
    t.uuid "fund_profile_id"
    t.text "name", null: false
    t.text "legal_name"
    t.enum "type", enum_type: "investment_vehicle_type"
    t.enum "fund_status", enum_type: "fund_status"
    t.enum "investing_status", enum_type: "investing_status"
    t.decimal "fund_size"
    t.decimal "target_size"
    t.integer "vintage_year"
    t.timestamptz "anouncement_date"
    t.decimal "min_lp_ticket"
    t.text "generation"
    t.decimal "aum"
    t.decimal "dry_powder_in_currency"
    t.decimal "dry_powder_in_usd"
    t.decimal "hurdle_rate"
    t.uuid "management_fee_id"
    t.text "other_fees"
    t.text "special_terms"
    t.integer "target_investments"
    t.integer "number_of_investments"
    t.decimal "carried_interest"
    t.boolean "super_carry"
    t.decimal "super_carry_threshold"
    t.decimal "super_carry_size"
    t.boolean "catch_up"
    t.boolean "claw_back"
    t.integer "annual_planned_investments"
    t.decimal "annual_planned_allocation_in_currency"
    t.timestamptz "last_investment"
    t.decimal "invested_capital"
    t.uuid "key_person_id"
    t.decimal "recycling"
    t.enum "distribution_waterfall", enum_type: "distribution_waterfall"
    t.timestamptz "target_closing_date"
    t.timestamptz "first_close_date"
    t.timestamptz "final_close_date"
    t.timestamptz "fundraising_start_date"
    t.integer "investment_period"
    t.decimal "gp_commitment"
    t.integer "jurisdiction"
    t.uuid "marketing_geographies_id"
    t.integer "fund_duration"
    t.integer "extended_fund_term"
    t.integer "number_of_investing_partners"
    t.text "description"
    t.integer "verifications", array: true
    t.text "logo_url"
    t.text "favicon_url"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["created_by_id"], name: "ix_investment_vehicles_created_by_id"
    t.index ["currency_id"], name: "ix_investment_vehicles_currency_id"
    t.index ["fund_profile_id"], name: "ix_investment_vehicles_fund_profile_id"
    t.index ["investor_id"], name: "ix_investment_vehicles_investor_id"
    t.index ["key_person_id"], name: "ix_investment_vehicles_key_person_id"
    t.index ["location_id"], name: "ix_investment_vehicles_location_id"
    t.index ["management_fee_id"], name: "ix_investment_vehicles_management_fee_id"
    t.index ["marketing_geographies_id"], name: "ix_investment_vehicles_marketing_geographies_id"
    t.index ["updated_by_id"], name: "ix_investment_vehicles_updated_by_id"
  end

  create_table "investment_vehicles_investment_strategies", primary_key: ["investment_vehicle_id", "investment_strategy_id"], force: :cascade do |t|
    t.uuid "investment_vehicle_id", null: false
    t.uuid "investment_strategy_id", null: false
    t.index ["investment_strategy_id"], name: "ix_investment_vehicles_investment_strategies_investment_strate"
  end

  create_table "investments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "investment_vehicle_id", null: false
    t.uuid "investment_entity_id", null: false
    t.uuid "currency_id"
    t.enum "asset_class", enum_type: "asset_class"
    t.timestamptz "investment_date"
    t.decimal "commitment_amount"
    t.decimal "called_amount"
    t.decimal "distributed_amount"
    t.boolean "highlighted", null: false
    t.uuid "investment_strategy_id"
    t.enum "status", enum_type: "investment_status"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_investments_created_by_id"
    t.index ["investment_entity_id"], name: "ix_investments_investment_entity_id"
    t.index ["investment_strategy_id"], name: "ix_investments_investment_strategy_id"
    t.index ["investment_vehicle_id"], name: "ix_investments_investment_vehicle_id"
    t.index ["updated_by_id"], name: "ix_investments_updated_by_id"
  end

  create_table "investor_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "investor_id", null: false
    t.text "first_name"
    t.text "last_name"
    t.text "email"
    t.text "alternative_email"
    t.timestamptz "date_of_birth"
    t.text "phone"
    t.text "source"
    t.text "role"
    t.enum "preferred_contact_method", enum_type: "preferred_contact_method"
    t.text "blurb"
    t.text "time_zone"
    t.text "linked_in_id"
    t.text "twitter_handle"
    t.timestamptz "last_contacted_at"
    t.timestamptz "next_followup_at"
    t.uuid "location_id"
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["created_by_id"], name: "ix_investor_contacts_created_by_id"
    t.index ["investor_id"], name: "ix_investor_contacts_investor_id"
    t.index ["location_id"], name: "ix_investor_contacts_location_id"
    t.index ["updated_by_id"], name: "ix_investor_contacts_updated_by_id"
  end

  create_table "investor_contacts_related", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "contact_id", null: false
    t.uuid "related_contact_id", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["contact_id"], name: "ix_investor_contacts_related_contact_id"
    t.index ["created_by_id"], name: "ix_investor_contacts_related_created_by_id"
    t.index ["related_contact_id"], name: "ix_investor_contacts_related_related_contact_id"
    t.index ["updated_by_id"], name: "ix_investor_contacts_related_updated_by_id"
  end

  create_table "investor_currencies", primary_key: ["investor_id", "currency_id"], force: :cascade do |t|
    t.uuid "investor_id", null: false
    t.uuid "currency_id", null: false
    t.index ["currency_id"], name: "ix_investor_currencies_currency_id"
  end

  create_table "investors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_profile_id"
    t.uuid "location_id"
    t.uuid "primary_contact_id"
    t.text "name", null: false
    t.enum "type", enum_type: "investor_type"
    t.text "legal_name"
    t.text "tax_id"
    t.text "website_url"
    t.text "linked_in_url"
    t.text "twitter_url"
    t.text "dealroom_url"
    t.text "crunchbase_url"
    t.decimal "aum_aprox_in_currency"
    t.decimal "aum_aprox_in_usd"
    t.decimal "dry_powder_approx"
    t.decimal "dry_powder_approx_in_usd"
    t.text "blurb"
    t.text "focus_sectors", default: [], null: false, array: true
    t.text "email_domain"
    t.timestamptz "established_date"
    t.text "description"
    t.text "logo_url"
    t.text "favicon_url"
    t.text "aqvc_url"
    t.text "wizard_id"
    t.integer "year_founded"
    t.boolean "qualified", null: false
    t.timestamptz "qualified_at_utc"
    t.uuid "qualified_by_id"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_investors_created_by_id"
    t.index ["location_id"], name: "ix_investors_location_id"
    t.index ["name"], name: "ix_investors_name"
    t.index ["organization_profile_id"], name: "ix_investors_organization_profile_id"
    t.index ["primary_contact_id"], name: "ix_investors_primary_contact_id"
    t.index ["qualified_by_id"], name: "ix_investors_qualified_by_id"
    t.index ["updated_by_id"], name: "ix_investors_updated_by_id"
  end

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "country_id", null: false
    t.text "street"
    t.text "address_line1"
    t.text "address_line2"
    t.text "postal_code"
    t.text "neighborhood"
    t.text "city"
    t.enum "location_type", null: false, enum_type: "location_type"
    t.decimal "latitude"
    t.decimal "longitude"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["country_id"], name: "ix_locations_country_id"
    t.index ["created_by_id"], name: "ix_locations_created_by_id"
    t.index ["updated_by_id"], name: "ix_locations_updated_by_id"
  end

  create_table "management_fees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "from_year", null: false
    t.integer "to_year", null: false
    t.decimal "fee_percent", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_management_fees_created_by_id"
    t.index ["updated_by_id"], name: "ix_management_fees_updated_by_id"
  end

  create_table "organization_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_profile_id", null: false
    t.uuid "investor_contact_reference_id", null: false
    t.text "first_name", null: false
    t.text "last_name", null: false
    t.text "email", null: false
    t.text "crm_link"
    t.text "phone"
    t.text "bio"
    t.text "source", null: false
    t.text "notes"
    t.text "group", default: "{}"
    t.enum "skills", enum_type: "contact_skill"
    t.text "tags", default: [], null: false, array: true
    t.text "groups", null: false, array: true
    t.text "related_contacts"
    t.text "potential_introducers"
    t.text "title"
    t.enum "preferred_contact_method", enum_type: "preferred_contact_method"
    t.text "potential_ticket_size"
    t.text "linked_in_id"
    t.text "twitter_handle"
    t.decimal "conviction"
    t.enum "pipeline_status", null: false, enum_type: "pipeline_status"
    t.uuid "owner_id", null: false
    t.enum "cadence", enum_type: "cadence"
    t.enum "relationship", null: false, enum_type: "relationship_status"
    t.timestamptz "last_contacted_at"
    t.timestamptz "next_followup_at"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_organization_contacts_created_by_id"
    t.index ["investor_contact_reference_id"], name: "ix_organization_contacts_investor_contact_reference_id"
    t.index ["organization_profile_id"], name: "ix_organization_contacts_organization_profile_id"
    t.index ["owner_id"], name: "ix_organization_contacts_owner_id"
    t.index ["updated_by_id"], name: "ix_organization_contacts_updated_by_id"
  end

  create_table "organization_contacts_alternate", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "contact_id", null: false
    t.uuid "alternate_contact_id", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["alternate_contact_id"], name: "ix_organization_contacts_alternate_alternate_contact_id"
    t.index ["contact_id"], name: "ix_organization_contacts_alternate_contact_id"
    t.index ["created_by_id"], name: "ix_organization_contacts_alternate_created_by_id"
    t.index ["updated_by_id"], name: "ix_organization_contacts_alternate_updated_by_id"
  end

  create_table "organization_marketing_details", primary_key: "organization_profile_id", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.enum "fund_closing_timeframe", enum_type: "fund_closing_timeframe"
    t.enum "cold_lp_marketing_openness", enum_type: "cold_lp_marketing_openness"
    t.enum "lp_marketing_budget", enum_type: "lp_marketing_budget"
    t.enum "fte_focus_on_lp_marketing_number", enum_type: "fte_focus_on_lp_marketing_number"
    t.enum "weekly_lp_leads_number", enum_type: "weekly_lp_leads_number"
    t.enum "organization_creator_role", enum_type: "organization_creator_role"
    t.enum "interests", null: false, array: true, enum_type: "organization_interests"
  end

  create_table "organization_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "organization_profile_id", null: false
    t.enum "organization_member_type", null: false, enum_type: "organization_member_type"
    t.timestamptz "joined_at", default: -> { "(now() AT TIME ZONE 'utc'::text)" }, null: false
    t.boolean "is_active", default: true, null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_organization_members_created_by_id"
    t.index ["organization_profile_id"], name: "ix_organization_members_organization_profile_id"
    t.index ["updated_by_id"], name: "ix_organization_members_updated_by_id"
    t.index ["user_id", "organization_profile_id"], name: "ix_organization_members_user_id_organization_profile_id", unique: true
  end

  create_table "organization_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "subdomain", limit: 63, null: false
    t.text "cs_manager_id"
    t.text "sales_manager_id"
    t.text "account_manager_id"
    t.text "crm_record_id"
    t.string "company_name", limit: 250, null: false
    t.string "company_legal_name", limit: 250, null: false
    t.integer "company_size_fte"
    t.text "website_url"
    t.uuid "billing_contact_id"
    t.text "billing_email"
    t.text "billing_phone"
    t.uuid "billing_address_id"
    t.timestamptz "fiscal_year_start"
    t.enum "organization_status", default: "active", null: false, enum_type: "organization_status"
    t.string "logo_key", limit: 500
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.uuid "user_id"
    t.index ["company_legal_name"], name: "ix_organization_profiles_company_legal_name", unique: true
    t.index ["company_name"], name: "ix_organization_profiles_company_name", unique: true
    t.index ["created_by_id"], name: "ix_organization_profiles_created_by_id"
    t.index ["subdomain"], name: "ix_organization_profiles_subdomain", unique: true
    t.index ["updated_by_id"], name: "ix_organization_profiles_updated_by_id"
    t.index ["user_id"], name: "ix_organization_profiles_user_id"
  end

  create_table "proof_ledger_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "investor_id"
    t.uuid "investment_vehicle_id"
    t.uuid "investment_strategy_id"
    t.uuid "investor_contact_id"
    t.uuid "investment_entity_id"
    t.uuid "proof_ledger_comment_reply_to_id"
    t.text "field_id", null: false
    t.text "comment", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_proof_ledger_comments_created_by_id"
    t.index ["investment_entity_id"], name: "ix_proof_ledger_comments_investment_entity_id"
    t.index ["investment_strategy_id"], name: "ix_proof_ledger_comments_investment_strategy_id"
    t.index ["investment_vehicle_id"], name: "ix_proof_ledger_comments_investment_vehicle_id"
    t.index ["investor_contact_id"], name: "ix_proof_ledger_comments_investor_contact_id"
    t.index ["investor_id"], name: "ix_proof_ledger_comments_investor_id"
    t.index ["proof_ledger_comment_reply_to_id"], name: "ix_proof_ledger_comments_proof_ledger_comment_reply_to_id"
    t.index ["updated_by_id"], name: "ix_proof_ledger_comments_updated_by_id"
  end

  create_table "proof_ledgers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "investor_id"
    t.uuid "investment_vehicle_id"
    t.uuid "investment_strategy_id"
    t.uuid "investor_contact_id"
    t.uuid "investment_entity_id"
    t.text "field_id", null: false
    t.enum "proof_type", null: false, enum_type: "proof_type"
    t.text "source_name"
    t.text "reference"
    t.text "raw_data_url"
    t.text "data_project_id"
    t.timestamptz "observed"
    t.text "criteria_name"
    t.text "criteria_value_old"
    t.text "criteria_value_new"
    t.text "proof_text"
    t.decimal "certainty_score"
    t.enum "status", null: false, enum_type: "proof_status"
    t.text "internal_comment"
    t.integer "version", null: false
    t.text "rational"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_proof_ledgers_created_by_id"
    t.index ["investment_entity_id"], name: "ix_proof_ledgers_investment_entity_id"
    t.index ["investment_strategy_id"], name: "ix_proof_ledgers_investment_strategy_id"
    t.index ["investment_vehicle_id"], name: "ix_proof_ledgers_investment_vehicle_id"
    t.index ["investor_contact_id"], name: "ix_proof_ledgers_investor_contact_id"
    t.index ["investor_id"], name: "ix_proof_ledgers_investor_id"
    t.index ["updated_by_id"], name: "ix_proof_ledgers_updated_by_id"
  end

  create_table "prospect_job_audit_trails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "prospect_job_id", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_prospect_job_audit_trails_created_by_id"
    t.index ["prospect_job_id"], name: "ix_prospect_job_audit_trails_prospect_job_id"
    t.index ["updated_by_id"], name: "ix_prospect_job_audit_trails_updated_by_id"
  end

  create_table "prospect_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "owner_id", null: false
    t.uuid "ideal_investor_profile_prospect_job_id", null: false
    t.uuid "fund_profile_id", null: false
    t.text "name", null: false
    t.timestamptz "due_date"
    t.interval "data_manager_time_spent"
    t.interval "account_manager_time_spent"
    t.text "data_manager"
    t.text "account_manager"
    t.enum "status", null: false, enum_type: "prospect_job_status"
    t.integer "number_of_prospects", null: false
    t.integer "number_of_bonus_prospects", null: false
    t.decimal "cost_per_prospect", null: false
    t.enum "priority", null: false, enum_type: "prospect_priority"
    t.timestamptz "started_at"
    t.timestamptz "delivered_at"
    t.decimal "qa_rejection_rate", null: false
    t.decimal "rejection_rate", null: false
    t.decimal "contacts_rate", null: false
    t.decimal "warm_intro_request_rate", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_prospect_jobs_created_by_id"
    t.index ["fund_profile_id"], name: "ix_prospect_jobs_fund_profile_id"
    t.index ["owner_id"], name: "ix_prospect_jobs_owner_id"
    t.index ["updated_by_id"], name: "ix_prospect_jobs_updated_by_id"
  end

  create_table "regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.text "code", null: false
    t.text "description"
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "role_claims", id: :serial, force: :cascade do |t|
    t.string "role_id", null: false
    t.text "claim_type"
    t.text "claim_value"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "normalized_name"
    t.text "concurrency_stamp"
    t.index ["normalized_name"], name: "index_roles_on_normalized_name", unique: true
  end

  create_table "similar_fund_and_company_iips", primary_key: ["similar_fund_and_company_id", "ideal_investor_profile_id"], force: :cascade do |t|
    t.uuid "ideal_investor_profile_id", null: false
    t.uuid "similar_fund_and_company_id", null: false
    t.index ["ideal_investor_profile_id"], name: "ix_similar_fund_and_company_iips_ideal_investor_profile_id"
  end

  create_table "similar_funds_and_companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 300, null: false
    t.string "website", limit: 300, null: false
    t.string "logo_url", limit: 500
    t.index ["name", "website"], name: "ix_similar_funds_and_companies_name_website", unique: true
    t.index ["website"], name: "ix_similar_funds_and_companies_website"
  end

  create_table "terms_and_conditions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "version", null: false
    t.text "version_link", null: false
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
  end

  create_table "user_claims", id: :serial, force: :cascade do |t|
    t.string "user_id", null: false
    t.text "claim_type"
    t.text "claim_value"
  end

  create_table "user_details_hub", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", limit: 50
    t.string "last_name", limit: 50
    t.timestamptz "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.timestamptz "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id"
    t.index ["created_by_id"], name: "ix_user_details_hub_created_by_id"
    t.index ["updated_by_id"], name: "ix_user_details_hub_updated_by_id"
  end

  create_table "user_logins", id: false, force: :cascade do |t|
    t.text "login_provider", null: false
    t.text "provider_key", null: false
    t.text "provider_display_name"
    t.string "user_id", null: false
  end

  create_table "user_refresh_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "token", null: false
    t.uuid "user_id", null: false
    t.datetime "expires_on_utc", null: false
    t.index ["token"], name: "index_user_refresh_tokens_on_token", unique: true
  end

  create_table "user_roles", id: false, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "role_id", null: false
  end

  create_table "user_tokens", id: false, force: :cascade do |t|
    t.string "user_id", null: false
    t.text "login_provider", null: false
    t.text "name", null: false
    t.text "value"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at_utc", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at_utc", default: -> { "CURRENT_TIMESTAMP" }
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.string "user_name"
    t.string "normalized_user_name"
    t.string "email"
    t.string "normalized_email"
    t.boolean "email_confirmed", null: false
    t.text "password_hash"
    t.text "security_stamp"
    t.text "concurrency_stamp"
    t.text "phone_number"
    t.boolean "phone_number_confirmed", null: false
    t.boolean "two_factor_enabled", null: false
    t.datetime "lockout_end"
    t.boolean "lockout_enabled", null: false
    t.integer "access_failed_count", null: false
    t.string "encrypted_password", default: "", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["normalized_email"], name: "index_users_on_normalized_email", unique: true
  end

  add_foreign_key "activities", "auth_hub.users", column: "created_by_id", name: "fk_activities_users_created_by_id", on_delete: :restrict
  add_foreign_key "activities", "auth_hub.users", column: "updated_by_id", name: "fk_activities_users_updated_by_id", on_delete: :restrict
  add_foreign_key "activities", "organization_contacts", name: "fk_activities_organization_contacts_organization_contact_id", on_delete: :cascade
  add_foreign_key "cities", "countries", name: "fk_cities_countries_country_id", on_delete: :cascade
  add_foreign_key "city_ideal_investor_profile", "cities", column: "investor_headquarters_id", name: "fk_city_ideal_investor_profile_cities_investor_headquarters_id", on_delete: :cascade
  add_foreign_key "city_ideal_investor_profile", "ideal_investor_profiles", column: "ideal_investor_profiles_id", name: "fk_city_ideal_investor_profile_ideal_investor_profiles_ideal_i", on_delete: :cascade
  add_foreign_key "countries", "currencies", name: "fk_countries_currencies_currency_id"
  add_foreign_key "countries", "regions", name: "fk_countries_regions_region_id", on_delete: :cascade
  add_foreign_key "engagement", "activities", name: "fk_engagement_activities_activity_id"
  add_foreign_key "engagement", "auth_hub.users", column: "created_by_id", name: "fk_engagement_users_created_by_id", on_delete: :restrict
  add_foreign_key "engagement", "auth_hub.users", column: "updated_by_id", name: "fk_engagement_users_updated_by_id", on_delete: :restrict
  add_foreign_key "engagement", "organization_contacts", name: "fk_engagement_organization_contacts_organization_contact_id", on_delete: :cascade
  add_foreign_key "events", "investors", name: "fk_events_investors_investor_id"
  add_foreign_key "feedback_ledgers", "auth_hub.users", column: "created_by_id", name: "fk_feedback_ledgers_users_created_by_id", on_delete: :restrict
  add_foreign_key "feedback_ledgers", "auth_hub.users", column: "updated_by_id", name: "fk_feedback_ledgers_users_updated_by_id", on_delete: :restrict
  add_foreign_key "feedback_ledgers", "proof_ledgers", name: "fk_feedback_ledgers_proof_ledgers_proof_ledger_id", on_delete: :cascade
  add_foreign_key "feedback_ledgers", "prospect_jobs", name: "fk_feedback_ledgers_prospect_jobs_prospect_job_id", on_delete: :cascade
  add_foreign_key "field_history", "auth_hub.users", column: "created_by_id", name: "fk_field_history_users_created_by_id", on_delete: :restrict
  add_foreign_key "field_history", "auth_hub.users", column: "updated_by_id", name: "fk_field_history_users_updated_by_id", on_delete: :restrict
  add_foreign_key "field_history", "investment_entities", name: "fk_field_history_investment_entities_investment_entity_id"
  add_foreign_key "field_history", "investment_strategies", name: "fk_field_history_investment_strategies_investment_strategy_id"
  add_foreign_key "field_history", "investment_vehicles", name: "fk_field_history_investment_vehicles_investment_vehicle_id"
  add_foreign_key "field_history", "investor_contacts", name: "fk_field_history_investor_contacts_investor_contact_id"
  add_foreign_key "field_history", "investors", name: "fk_field_history_investors_investor_id"
  add_foreign_key "fund_profiles", "auth_hub.users", column: "created_by_id", name: "fk_fund_profiles_users_created_by_id", on_delete: :restrict
  add_foreign_key "fund_profiles", "auth_hub.users", column: "updated_by_id", name: "fk_fund_profiles_users_updated_by_id", on_delete: :restrict
  add_foreign_key "fund_profiles", "investor_contacts", column: "fund_manager_id", name: "fk_fund_profiles_investor_contacts_fund_manager_id", on_delete: :cascade
  add_foreign_key "fund_profiles", "organization_profiles", name: "fk_fund_profiles_organization_profiles_organization_profile_id", on_delete: :cascade
  add_foreign_key "ideal_investor_profile_country_focus", "countries", name: "fk_ideal_investor_profile_country_focus_countries_country_id", on_delete: :cascade
  add_foreign_key "ideal_investor_profile_country_focus", "ideal_investor_profiles", name: "fk_ideal_investor_profile_country_focus_ideal_investor_profile", on_delete: :cascade
  add_foreign_key "ideal_investor_profile_prospect_jobs", "auth_hub.users", column: "created_by_id", name: "fk_ideal_investor_profile_prospect_jobs_users_created_by_id", on_delete: :restrict
  add_foreign_key "ideal_investor_profile_prospect_jobs", "auth_hub.users", column: "updated_by_id", name: "fk_ideal_investor_profile_prospect_jobs_users_updated_by_id", on_delete: :restrict
  add_foreign_key "ideal_investor_profile_prospect_jobs", "ideal_investor_profiles", name: "fk_ideal_investor_profile_prospect_jobs_ideal_investor_profile", on_delete: :cascade
  add_foreign_key "ideal_investor_profile_prospect_jobs", "prospect_jobs", name: "fk_ideal_investor_profile_prospect_jobs_prospect_jobs_prospect", on_delete: :cascade
  add_foreign_key "ideal_investor_profile_region_focus", "ideal_investor_profiles", name: "fk_ideal_investor_profile_region_focus_ideal_investor_profiles", on_delete: :cascade
  add_foreign_key "ideal_investor_profile_region_focus", "regions", name: "fk_ideal_investor_profile_region_focus_regions_region_id", on_delete: :cascade
  add_foreign_key "ideal_investor_profiles", "auth_hub.users", column: "created_by_id", name: "fk_ideal_investor_profiles_users_created_by_id", on_delete: :restrict
  add_foreign_key "ideal_investor_profiles", "auth_hub.users", column: "updated_by_id", name: "fk_ideal_investor_profiles_users_updated_by_id", on_delete: :restrict
  add_foreign_key "ideal_investor_profiles", "countries", column: "country_headquarter_id", name: "fk_ideal_investor_profiles_countries_country_headquarter_id"
  add_foreign_key "ideal_investor_profiles", "fund_profiles", name: "fk_ideal_investor_profiles_fund_profiles_fund_profile_id"
  add_foreign_key "ideal_investor_profiles", "organization_profiles", name: "fk_ideal_investor_profiles_organization_profiles_organization_", on_delete: :cascade
  add_foreign_key "ideal_investor_profiles", "regions", column: "region_headquarter_id", name: "fk_ideal_investor_profiles_regions_region_headquarter_id"
  add_foreign_key "iip_prospect_investor_contacts", "auth_hub.users", column: "created_by_id", name: "fk_iip_prospect_investor_contacts_users_created_by_id", on_delete: :restrict
  add_foreign_key "iip_prospect_investor_contacts", "auth_hub.users", column: "updated_by_id", name: "fk_iip_prospect_investor_contacts_users_updated_by_id", on_delete: :restrict
  add_foreign_key "iip_prospect_investor_contacts", "iip_prospects", column: "iip_prospects_id", name: "fk_iip_prospect_investor_contacts_iip_prospects_iip_prospects_", on_delete: :cascade
  add_foreign_key "iip_prospect_investor_contacts", "investor_contacts", name: "fk_iip_prospect_investor_contacts_investor_contacts_investor_c", on_delete: :cascade
  add_foreign_key "iip_prospects", "auth_hub.users", column: "created_by_id", name: "fk_iip_prospects_users_created_by_id", on_delete: :restrict
  add_foreign_key "iip_prospects", "auth_hub.users", column: "updated_by_id", name: "fk_iip_prospects_users_updated_by_id", on_delete: :restrict
  add_foreign_key "iip_prospects", "investment_vehicles", name: "fk_iip_prospects_investment_vehicles_investment_vehicle_id", on_delete: :cascade
  add_foreign_key "iip_prospects", "organization_contacts", name: "fk_iip_prospects_organization_contacts_organization_contact_id", on_delete: :cascade
  add_foreign_key "iip_prospects", "prospect_jobs", name: "fk_iip_prospects_prospect_jobs_prospect_job_id", on_delete: :cascade
  add_foreign_key "investment_entities", "auth_hub.users", column: "created_by_id", name: "fk_investment_entities_users_created_by_id", on_delete: :restrict
  add_foreign_key "investment_entities", "auth_hub.users", column: "updated_by_id", name: "fk_investment_entities_users_updated_by_id", on_delete: :restrict
  add_foreign_key "investment_entities", "investment_vehicles", name: "fk_investment_entities_investment_vehicles_investment_vehicle_", on_delete: :cascade
  add_foreign_key "investment_entities", "locations", column: "headquarters_address_id", name: "fk_investment_entities_locations_headquarters_address_id"
  add_foreign_key "investment_entities", "locations", name: "fk_investment_entities_locations_location_id"
  add_foreign_key "investment_strategies", "auth_hub.users", column: "created_by_id", name: "fk_investment_strategies_users_created_by_id", on_delete: :restrict
  add_foreign_key "investment_strategies", "auth_hub.users", column: "updated_by_id", name: "fk_investment_strategies_users_updated_by_id", on_delete: :restrict
  add_foreign_key "investment_strategies", "countries", column: "country_headquarter_id", name: "fk_investment_strategies_countries_country_headquarter_id"
  add_foreign_key "investment_strategies", "investor_contacts", name: "fk_investment_strategies_investor_contacts_investor_contact_id"
  add_foreign_key "investment_strategies", "investors", name: "fk_investment_strategies_investors_investor_id"
  add_foreign_key "investment_strategies", "regions", column: "region_headquarter_id", name: "fk_investment_strategies_regions_region_headquarter_id"
  add_foreign_key "investment_strategy_country_focus", "countries", name: "fk_investment_strategy_country_focus_countries_country_id", on_delete: :cascade
  add_foreign_key "investment_strategy_country_focus", "investment_strategies", name: "fk_investment_strategy_country_focus_investment_strategies_inv", on_delete: :cascade
  add_foreign_key "investment_strategy_region_focus", "investment_strategies", name: "fk_investment_strategy_region_focus_investment_strategies_inve", on_delete: :cascade
  add_foreign_key "investment_strategy_region_focus", "regions", name: "fk_investment_strategy_region_focus_regions_region_id", on_delete: :cascade
  add_foreign_key "investment_vehicle_key_contacts", "auth_hub.users", column: "created_by_id", name: "fk_investment_vehicle_key_contacts_users_created_by_id", on_delete: :restrict
  add_foreign_key "investment_vehicle_key_contacts", "auth_hub.users", column: "updated_by_id", name: "fk_investment_vehicle_key_contacts_users_updated_by_id", on_delete: :restrict
  add_foreign_key "investment_vehicle_key_contacts", "investment_vehicles", name: "fk_investment_vehicle_key_contacts_investment_vehicles_investm", on_delete: :cascade
  add_foreign_key "investment_vehicle_key_contacts", "investor_contacts", name: "fk_investment_vehicle_key_contacts_investor_contacts_investor_", on_delete: :cascade
  add_foreign_key "investment_vehicles", "auth_hub.users", column: "created_by_id", name: "fk_investment_vehicles_users_created_by_id", on_delete: :restrict
  add_foreign_key "investment_vehicles", "auth_hub.users", column: "updated_by_id", name: "fk_investment_vehicles_users_updated_by_id", on_delete: :restrict
  add_foreign_key "investment_vehicles", "currencies", name: "fk_investment_vehicles_currencies_currency_id"
  add_foreign_key "investment_vehicles", "fund_profiles", name: "fk_investment_vehicles_fund_profiles_fund_profile_id"
  add_foreign_key "investment_vehicles", "investor_contacts", column: "key_person_id", name: "fk_investment_vehicles_investor_contacts_key_person_id"
  add_foreign_key "investment_vehicles", "investors", name: "fk_investment_vehicles_investors_investor_id", on_delete: :cascade
  add_foreign_key "investment_vehicles", "locations", column: "marketing_geographies_id", name: "fk_investment_vehicles_locations_marketing_geographies_id"
  add_foreign_key "investment_vehicles", "locations", name: "fk_investment_vehicles_locations_location_id"
  add_foreign_key "investment_vehicles", "management_fees", name: "fk_investment_vehicles_management_fees_management_fee_id"
  add_foreign_key "investment_vehicles_investment_strategies", "investment_strategies", name: "fk_investment_vehicles_investment_strategies_investment_strate", on_delete: :cascade
  add_foreign_key "investment_vehicles_investment_strategies", "investment_vehicles", name: "fk_investment_vehicles_investment_strategies_investment_vehicl", on_delete: :cascade
  add_foreign_key "investments", "auth_hub.users", column: "created_by_id", name: "fk_investments_users_created_by_id", on_delete: :restrict
  add_foreign_key "investments", "auth_hub.users", column: "updated_by_id", name: "fk_investments_users_updated_by_id", on_delete: :restrict
  add_foreign_key "investments", "investment_entities", name: "fk_investments_investment_entities_investment_entity_id", on_delete: :cascade
  add_foreign_key "investments", "investment_strategies", name: "fk_investments_investment_strategies_investment_strategy_id"
  add_foreign_key "investments", "investment_vehicles", name: "fk_investments_investment_vehicles_investment_vehicle_id", on_delete: :cascade
  add_foreign_key "investor_contacts", "auth_hub.users", column: "created_by_id", name: "fk_investor_contacts_users_created_by_id", on_delete: :restrict
  add_foreign_key "investor_contacts", "auth_hub.users", column: "updated_by_id", name: "fk_investor_contacts_users_updated_by_id", on_delete: :restrict
  add_foreign_key "investor_contacts", "investors", name: "fk_investor_contacts_investors_investor_id", on_delete: :cascade
  add_foreign_key "investor_contacts", "locations", name: "fk_investor_contacts_locations_location_id"
  add_foreign_key "investor_contacts_related", "auth_hub.users", column: "created_by_id", name: "fk_investor_contacts_related_users_created_by_id", on_delete: :restrict
  add_foreign_key "investor_contacts_related", "auth_hub.users", column: "updated_by_id", name: "fk_investor_contacts_related_users_updated_by_id", on_delete: :restrict
  add_foreign_key "investor_contacts_related", "investor_contacts", column: "contact_id", name: "fk_investor_contacts_related_investor_contacts_contact_id", on_delete: :cascade
  add_foreign_key "investor_contacts_related", "investor_contacts", column: "related_contact_id", name: "fk_investor_contacts_related_investor_contacts_related_contact", on_delete: :cascade
  add_foreign_key "investor_currencies", "currencies", name: "fk_investor_currencies_currencies_currency_id", on_delete: :cascade
  add_foreign_key "investor_currencies", "investors", name: "fk_investor_currencies_investors_investor_id", on_delete: :cascade
  add_foreign_key "investors", "auth_hub.users", column: "created_by_id", name: "fk_investors_users_created_by_id", on_delete: :restrict
  add_foreign_key "investors", "auth_hub.users", column: "qualified_by_id", name: "fk_investors_users_qualified_by_id", on_delete: :restrict
  add_foreign_key "investors", "auth_hub.users", column: "updated_by_id", name: "fk_investors_users_updated_by_id", on_delete: :restrict
  add_foreign_key "investors", "investor_contacts", column: "primary_contact_id", name: "fk_investors_investor_contacts_primary_contact_id"
  add_foreign_key "investors", "locations", name: "fk_investors_locations_location_id"
  add_foreign_key "investors", "organization_profiles", name: "fk_investors_organization_profiles_organization_profile_id"
  add_foreign_key "locations", "auth_hub.users", column: "created_by_id", name: "fk_locations_users_created_by_id", on_delete: :restrict
  add_foreign_key "locations", "auth_hub.users", column: "updated_by_id", name: "fk_locations_users_updated_by_id", on_delete: :restrict
  add_foreign_key "locations", "countries", name: "fk_locations_countries_country_id", on_delete: :cascade
  add_foreign_key "management_fees", "auth_hub.users", column: "created_by_id", name: "fk_management_fees_users_created_by_id", on_delete: :restrict
  add_foreign_key "management_fees", "auth_hub.users", column: "updated_by_id", name: "fk_management_fees_users_updated_by_id", on_delete: :restrict
  add_foreign_key "organization_contacts", "auth_hub.users", column: "created_by_id", name: "fk_organization_contacts_users_created_by_id", on_delete: :restrict
  add_foreign_key "organization_contacts", "auth_hub.users", column: "owner_id", name: "fk_organization_contacts_users_owner_id", on_delete: :cascade
  add_foreign_key "organization_contacts", "auth_hub.users", column: "updated_by_id", name: "fk_organization_contacts_users_updated_by_id", on_delete: :restrict
  add_foreign_key "organization_contacts", "investor_contacts", column: "investor_contact_reference_id", name: "fk_organization_contacts_investor_contacts_investor_contact_re", on_delete: :cascade
  add_foreign_key "organization_contacts", "organization_profiles", name: "fk_organization_contacts_organization_profiles_organization_pr", on_delete: :cascade
  add_foreign_key "organization_contacts_alternate", "auth_hub.users", column: "created_by_id", name: "fk_organization_contacts_alternate_users_created_by_id", on_delete: :restrict
  add_foreign_key "organization_contacts_alternate", "auth_hub.users", column: "updated_by_id", name: "fk_organization_contacts_alternate_users_updated_by_id", on_delete: :restrict
  add_foreign_key "organization_contacts_alternate", "organization_contacts", column: "alternate_contact_id", name: "fk_organization_contacts_alternate_organization_contacts_alter", on_delete: :cascade
  add_foreign_key "organization_contacts_alternate", "organization_contacts", column: "contact_id", name: "fk_organization_contacts_alternate_organization_contacts_conta", on_delete: :restrict
  add_foreign_key "organization_marketing_details", "organization_profiles", name: "fk_organization_marketing_details_organization_profiles_organi", on_delete: :cascade
  add_foreign_key "organization_members", "auth_hub.users", column: "created_by_id", name: "fk_organization_members_users_created_by_id", on_delete: :restrict
  add_foreign_key "organization_members", "auth_hub.users", column: "updated_by_id", name: "fk_organization_members_users_updated_by_id", on_delete: :restrict
  add_foreign_key "organization_members", "auth_hub.users", column: "user_id", name: "fk_organization_members_users_user_id", on_delete: :cascade
  add_foreign_key "organization_members", "organization_profiles", name: "fk_organization_members_organization_profiles_organization_pro", on_delete: :cascade
  add_foreign_key "organization_profiles", "auth_hub.users", column: "created_by_id", name: "fk_organization_profiles_users_created_by_id", on_delete: :restrict
  add_foreign_key "organization_profiles", "auth_hub.users", column: "updated_by_id", name: "fk_organization_profiles_users_updated_by_id", on_delete: :restrict
  add_foreign_key "organization_profiles", "auth_hub.users", column: "user_id", name: "fk_organization_profiles_users_user_id"
  add_foreign_key "proof_ledger_comments", "auth_hub.users", column: "created_by_id", name: "fk_proof_ledger_comments_users_created_by_id", on_delete: :restrict
  add_foreign_key "proof_ledger_comments", "auth_hub.users", column: "updated_by_id", name: "fk_proof_ledger_comments_users_updated_by_id", on_delete: :restrict
  add_foreign_key "proof_ledger_comments", "investment_entities", name: "fk_proof_ledger_comments_investment_entities_investment_entity"
  add_foreign_key "proof_ledger_comments", "investment_strategies", name: "fk_proof_ledger_comments_investment_strategies_investment_stra"
  add_foreign_key "proof_ledger_comments", "investment_vehicles", name: "fk_proof_ledger_comments_investment_vehicles_investment_vehicl"
  add_foreign_key "proof_ledger_comments", "investor_contacts", name: "fk_proof_ledger_comments_investor_contacts_investor_contact_id"
  add_foreign_key "proof_ledger_comments", "investors", name: "fk_proof_ledger_comments_investors_investor_id"
  add_foreign_key "proof_ledger_comments", "proof_ledger_comments", column: "proof_ledger_comment_reply_to_id", name: "fk_proof_ledger_comments_proof_ledger_comments_proof_ledger_co"
  add_foreign_key "proof_ledgers", "auth_hub.users", column: "created_by_id", name: "fk_proof_ledgers_users_created_by_id", on_delete: :restrict
  add_foreign_key "proof_ledgers", "auth_hub.users", column: "updated_by_id", name: "fk_proof_ledgers_users_updated_by_id", on_delete: :restrict
  add_foreign_key "proof_ledgers", "investment_entities", name: "fk_proof_ledgers_investment_entities_investment_entity_id"
  add_foreign_key "proof_ledgers", "investment_strategies", name: "fk_proof_ledgers_investment_strategies_investment_strategy_id"
  add_foreign_key "proof_ledgers", "investment_vehicles", name: "fk_proof_ledgers_investment_vehicles_investment_vehicle_id"
  add_foreign_key "proof_ledgers", "investor_contacts", name: "fk_proof_ledgers_investor_contacts_investor_contact_id"
  add_foreign_key "proof_ledgers", "investors", name: "fk_proof_ledgers_investors_investor_id"
  add_foreign_key "prospect_job_audit_trails", "auth_hub.users", column: "created_by_id", name: "fk_prospect_job_audit_trails_users_created_by_id", on_delete: :restrict
  add_foreign_key "prospect_job_audit_trails", "auth_hub.users", column: "updated_by_id", name: "fk_prospect_job_audit_trails_users_updated_by_id", on_delete: :restrict
  add_foreign_key "prospect_job_audit_trails", "prospect_jobs", name: "fk_prospect_job_audit_trails_prospect_jobs_prospect_job_id", on_delete: :cascade
  add_foreign_key "prospect_jobs", "auth_hub.users", column: "created_by_id", name: "fk_prospect_jobs_users_created_by_id", on_delete: :restrict
  add_foreign_key "prospect_jobs", "auth_hub.users", column: "owner_id", name: "fk_prospect_jobs_users_owner_id", on_delete: :cascade
  add_foreign_key "prospect_jobs", "auth_hub.users", column: "updated_by_id", name: "fk_prospect_jobs_users_updated_by_id", on_delete: :restrict
  add_foreign_key "prospect_jobs", "fund_profiles", name: "fk_prospect_jobs_fund_profiles_fund_profile_id", on_delete: :cascade
  add_foreign_key "similar_fund_and_company_iips", "ideal_investor_profiles", name: "fk_similar_fund_and_company_iips_ideal_investor_profiles_ideal", on_delete: :cascade
  add_foreign_key "similar_fund_and_company_iips", "similar_funds_and_companies", column: "similar_fund_and_company_id", name: "fk_similar_fund_and_company_iips_similar_funds_and_companies_s", on_delete: :cascade
  add_foreign_key "user_details_hub", "auth_hub.users", column: "created_by_id", name: "fk_user_details_hub_users_created_by_id", on_delete: :restrict
  add_foreign_key "user_details_hub", "auth_hub.users", column: "id", name: "fk_user_details_hub_users_id", on_delete: :cascade
  add_foreign_key "user_details_hub", "auth_hub.users", column: "updated_by_id", name: "fk_user_details_hub_users_updated_by_id", on_delete: :restrict
end
