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

ActiveRecord::Schema[7.0].define(version: 2026_03_24_000056) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "__ef_migrations_history", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "product_version", null: false
  end

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "organization_contact_id", null: false
    t.text "activity_name", null: false
    t.text "description"
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.integer "reference_id"
    t.string "type", null: false
    t.string "status", null: false
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "cities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "country_id", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "city_ideal_investor_profile", id: false, force: :cascade do |t|
    t.string "ideal_investor_profiles_id", null: false
    t.string "investor_headquarters_id", null: false
  end

  create_table "countries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "region_id", null: false
    t.text "name", null: false
    t.text "iso_code", null: false
    t.text "iso3code", null: false
    t.text "calling_code", null: false
    t.string "currency_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "currencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.string "symbol"
    t.string "code"
    t.integer "decimal_places"
    t.boolean "is_active", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "engagement", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "organization_contact_id", null: false
    t.text "engagement_name", null: false
    t.datetime "engagement_date"
    t.string "activity_id"
    t.text "description"
    t.text "sentiment_type"
    t.text "sentiment_context"
    t.integer "reference_id"
    t.string "type", null: false
    t.string "status", null: false
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.string "investor_id"
  end

  create_table "feedback_ledgers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "proof_ledger_id", null: false
    t.string "prospect_job_id", null: false
    t.text "criteria_name"
    t.text "criteria_value"
    t.text "proof_text"
    t.text "feedback"
    t.integer "feedback_score"
    t.datetime "feedback_date"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "field_history", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "investor_id"
    t.string "investment_vehicle_id"
    t.string "investment_strategy_id"
    t.string "investor_contact_id"
    t.string "investment_entity_id"
    t.text "field_id", null: false
    t.text "criteria_name"
    t.text "criteria_value_old"
    t.text "criteria_value_new"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "fund_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "organization_profile_id", null: false
    t.string "fund_manager_id", null: false
    t.text "fund_name", null: false
    t.string "type", null: false
    t.string "sector_focus", null: false, array: true
    t.string "stage_focus", null: false, array: true
    t.string "geography_focus", null: false, array: true
    t.text "fund_generation"
    t.decimal "target_fund_size"
    t.integer "vintage_year"
    t.string "maturity", null: false
    t.decimal "min_ticket"
    t.datetime "close_date"
    t.datetime "launch_date"
    t.string "fund_structure", null: false
    t.hstore "fees"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "ideal_investor_profile_country_focus", id: false, force: :cascade do |t|
    t.string "ideal_investor_profile_id", null: false
    t.string "country_id", null: false
  end

  create_table "ideal_investor_profile_prospect_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "prospect_job_id", null: false
    t.string "ideal_investor_profile_id", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "ideal_investor_profile_region_focus", id: false, force: :cascade do |t|
    t.string "ideal_investor_profile_id", null: false
    t.string "region_id", null: false
  end

  create_table "ideal_investor_profile_suggestions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "briefing"
    t.boolean "is_active", default: true, null: false
    t.decimal "min_check_size", precision: 18, scale: 2
    t.decimal "max_check_size", precision: 18, scale: 2
    t.text "thematic_keywords", array: true
    t.string "investor_type", array: true
    t.string "asset_class", null: false, array: true
    t.string "maturity_focus", array: true
    t.string "sector_focus", null: false, array: true
    t.string "stage_focus", array: true
    t.string "strategy_focus", array: true
    t.string "targeting_approach"
  end

  create_table "ideal_investor_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "organization_profile_id", null: false
    t.string "name", null: false
    t.string "description"
    t.string "iip_status", default: "active", null: false
    t.datetime "due_date", null: false
    t.integer "target_nr_of_prospects_to_generate", null: false
    t.string "asset_class", null: false, array: true
    t.string "sector_focus", null: false, array: true
    t.string "investor_type", array: true
    t.string "maturity_focus", array: true
    t.string "stage_focus", array: true
    t.decimal "min_check_size", precision: 18, scale: 2
    t.decimal "max_check_size", precision: 18, scale: 2
    t.string "targeting_approach"
    t.text "thematic_keywords", array: true
    t.string "briefing"
    t.string "fund_profile_id"
    t.string "strategy_focus", array: true
    t.string "region_headquarter_id"
    t.string "country_headquarter_id"
    t.text "city_headquarter"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "iip_prospect_investor_contacts", id: false, force: :cascade do |t|
    t.string "investor_contact_id", null: false
    t.string "iip_prospects_id", null: false
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "iip_prospects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "prospect_job_id", null: false
    t.string "investment_vehicle_id", null: false
    t.string "organization_contact_id", null: false
    t.string "status", null: false
    t.text "rejection_reason"
    t.text "rejection_reason_qa"
    t.text "rejection_reason_qa_code"
    t.text "rejection_reason_code"
    t.decimal "matched_score"
    t.boolean "warm_intro_requested", null: false
    t.text "data_manager_comment"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "investment_entities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "location_id"
    t.string "investment_vehicle_id", null: false
    t.text "name"
    t.text "legal_name"
    t.string "legal_status"
    t.text "website_url"
    t.text "favicon_url"
    t.text "logo_url"
    t.string "sector"
    t.string "type"
    t.string "headquarters_address_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "investment_strategies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "investor_id"
    t.string "investor_contact_id"
    t.text "name"
    t.decimal "aum"
    t.integer "target_investments"
    t.integer "experience_in_years"
    t.text "program"
    t.string "investor_type_focus", default: [], null: false, array: true
    t.string "sector_investment_focus", default: [], null: false, array: true
    t.string "maturity_focus", default: [], null: false, array: true
    t.string "stage_focus", default: [], null: false, array: true
    t.string "asset_class_focus", default: [], null: false, array: true
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
    t.string "business_type"
    t.string "revenue_type"
    t.string "founder_type"
    t.string "asset_type"
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
    t.string "strategy_focus", default: [], null: false, array: true
    t.string "region_headquarter_id"
    t.string "country_headquarter_id"
    t.text "city_headquarter"
    t.text "events_attendance", array: true
    t.text "keywords", array: true
    t.integer "risk_tolerance"
    t.text "esg_preferences", array: true
    t.boolean "esg_sdg_focus"
    t.hstore "geo_targeting"
    t.hstore "score_weightings"
    t.text "note"
    t.datetime "last_modified_at"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "investment_strategy_country_focus", id: false, force: :cascade do |t|
    t.string "investment_strategy_id", null: false
    t.string "country_id", null: false
  end

  create_table "investment_strategy_region_focus", id: false, force: :cascade do |t|
    t.string "investment_strategy_id", null: false
    t.string "region_id", null: false
  end

  create_table "investment_vehicle_key_contacts", id: false, force: :cascade do |t|
    t.string "investment_vehicle_id", null: false
    t.string "investor_contact_id", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "investment_vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "investor_id", null: false
    t.string "currency_id"
    t.string "location_id"
    t.string "fund_profile_id"
    t.text "name", null: false
    t.text "legal_name"
    t.string "type"
    t.string "fund_status"
    t.string "investing_status"
    t.decimal "fund_size"
    t.decimal "target_size"
    t.integer "vintage_year"
    t.datetime "anouncement_date"
    t.decimal "min_lp_ticket"
    t.text "generation"
    t.decimal "aum"
    t.decimal "dry_powder_in_currency"
    t.decimal "dry_powder_in_usd"
    t.decimal "hurdle_rate"
    t.string "management_fee_id"
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
    t.datetime "last_investment"
    t.decimal "invested_capital"
    t.string "key_person_id"
    t.decimal "recycling"
    t.string "distribution_waterfall"
    t.datetime "target_closing_date"
    t.datetime "first_close_date"
    t.datetime "final_close_date"
    t.datetime "fundraising_start_date"
    t.integer "investment_period"
    t.decimal "gp_commitment"
    t.integer "jurisdiction"
    t.string "marketing_geographies_id"
    t.integer "fund_duration"
    t.integer "extended_fund_term"
    t.integer "number_of_investing_partners"
    t.text "description"
    t.integer "verifications", array: true
    t.text "logo_url"
    t.text "favicon_url"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "investment_vehicles_investment_strategies", id: false, force: :cascade do |t|
    t.string "investment_vehicle_id", null: false
    t.string "investment_strategy_id", null: false
  end

  create_table "investments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "investment_vehicle_id", null: false
    t.string "investment_entity_id", null: false
    t.string "currency_id"
    t.string "asset_class"
    t.datetime "investment_date"
    t.decimal "commitment_amount"
    t.decimal "called_amount"
    t.decimal "distributed_amount"
    t.boolean "highlighted", null: false
    t.string "investment_strategy_id"
    t.string "status"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "investor_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "investor_id", null: false
    t.text "first_name"
    t.text "last_name"
    t.text "email"
    t.text "alternative_email"
    t.datetime "date_of_birth"
    t.text "phone"
    t.text "source"
    t.text "role"
    t.string "preferred_contact_method"
    t.text "blurb"
    t.text "time_zone"
    t.text "linked_in_id"
    t.text "twitter_handle"
    t.datetime "last_contacted_at"
    t.datetime "next_followup_at"
    t.string "location_id"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
  end

  create_table "investor_contacts_related", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "contact_id", null: false
    t.string "related_contact_id", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "investor_currencies", id: false, force: :cascade do |t|
    t.string "investor_id", null: false
    t.string "currency_id", null: false
  end

  create_table "investors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "organization_profile_id"
    t.string "location_id"
    t.string "primary_contact_id"
    t.text "name", null: false
    t.string "type"
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
    t.datetime "established_date"
    t.text "description"
    t.text "logo_url"
    t.text "favicon_url"
    t.text "aqvc_url"
    t.text "wizard_id"
    t.integer "year_founded"
    t.boolean "qualified", null: false
    t.datetime "qualified_at_utc"
    t.string "qualified_by_id"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "country_id", null: false
    t.text "street"
    t.text "address_line1"
    t.text "address_line2"
    t.text "postal_code"
    t.text "neighborhood"
    t.text "city"
    t.string "location_type", null: false
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "management_fees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "from_year", null: false
    t.integer "to_year", null: false
    t.decimal "fee_percent", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "organization_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "organization_profile_id", null: false
    t.string "investor_contact_reference_id", null: false
    t.text "first_name", null: false
    t.text "last_name", null: false
    t.text "email", null: false
    t.text "crm_link"
    t.text "phone"
    t.text "bio"
    t.text "source", null: false
    t.text "notes"
    t.text "group", default: "{}"
    t.string "skills"
    t.text "tags", default: [], null: false, array: true
    t.text "groups", null: false, array: true
    t.text "related_contacts"
    t.text "potential_introducers"
    t.text "title"
    t.string "preferred_contact_method"
    t.text "potential_ticket_size"
    t.text "linked_in_id"
    t.text "twitter_handle"
    t.decimal "conviction"
    t.string "pipeline_status", null: false
    t.string "owner_id", null: false
    t.string "cadence"
    t.string "relationship", null: false
    t.datetime "last_contacted_at"
    t.datetime "next_followup_at"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "organization_contacts_alternate", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "contact_id", null: false
    t.string "alternate_contact_id", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "organization_marketing_details", primary_key: "organization_profile_id", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "fund_closing_timeframe"
    t.string "cold_lp_marketing_openness"
    t.string "lp_marketing_budget"
    t.string "fte_focus_on_lp_marketing_number"
    t.string "weekly_lp_leads_number"
    t.string "organization_creator_role"
    t.string "interests", null: false, array: true
  end

  create_table "organization_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "user_id", null: false
    t.string "organization_profile_id", null: false
    t.string "organization_member_type", null: false
    t.datetime "joined_at", default: -> { "(now() AT TIME ZONE 'utc'::text)" }, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "organization_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "subdomain", null: false
    t.text "cs_manager_id"
    t.text "sales_manager_id"
    t.text "account_manager_id"
    t.text "crm_record_id"
    t.string "company_name", null: false
    t.string "company_legal_name", null: false
    t.integer "company_size_fte"
    t.text "website_url"
    t.string "billing_contact_id"
    t.text "billing_email"
    t.text "billing_phone"
    t.string "billing_address_id"
    t.datetime "fiscal_year_start"
    t.string "organization_status", default: "active", null: false
    t.string "logo_key"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
    t.string "user_id"
  end

  create_table "proof_ledger_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "investor_id"
    t.string "investment_vehicle_id"
    t.string "investment_strategy_id"
    t.string "investor_contact_id"
    t.string "investment_entity_id"
    t.string "proof_ledger_comment_reply_to_id"
    t.text "field_id", null: false
    t.text "comment", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "proof_ledgers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "investor_id"
    t.string "investment_vehicle_id"
    t.string "investment_strategy_id"
    t.string "investor_contact_id"
    t.string "investment_entity_id"
    t.text "field_id", null: false
    t.string "proof_type", null: false
    t.text "source_name"
    t.text "reference"
    t.text "raw_data_url"
    t.text "data_project_id"
    t.datetime "observed"
    t.text "criteria_name"
    t.text "criteria_value_old"
    t.text "criteria_value_new"
    t.text "proof_text"
    t.decimal "certainty_score"
    t.string "status", null: false
    t.text "internal_comment"
    t.integer "version", null: false
    t.text "rational"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "prospect_job_audit_trails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "prospect_job_id", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "prospect_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "owner_id", null: false
    t.string "ideal_investor_profile_prospect_job_id", null: false
    t.string "fund_profile_id", null: false
    t.text "name", null: false
    t.datetime "due_date"
    t.interval "data_manager_time_spent"
    t.interval "account_manager_time_spent"
    t.text "data_manager"
    t.text "account_manager"
    t.string "status", null: false
    t.integer "number_of_prospects", null: false
    t.integer "number_of_bonus_prospects", null: false
    t.decimal "cost_per_prospect", null: false
    t.string "priority", null: false
    t.datetime "started_at"
    t.datetime "delivered_at"
    t.decimal "qa_rejection_rate", null: false
    t.decimal "rejection_rate", null: false
    t.decimal "contacts_rate", null: false
    t.decimal "warm_intro_request_rate", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.text "code", null: false
    t.text "description"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
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

  create_table "similar_fund_and_company_iips", id: false, force: :cascade do |t|
    t.string "ideal_investor_profile_id", null: false
    t.string "similar_fund_and_company_id", null: false
  end

  create_table "similar_funds_and_companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "website", null: false
    t.string "logo_url"
  end

  create_table "terms_and_conditions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "version", null: false
    t.text "version_link", null: false
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
  end

  create_table "user_claims", id: :serial, force: :cascade do |t|
    t.string "user_id", null: false
    t.text "claim_type"
    t.text "claim_value"
  end

  create_table "user_details_hub", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
    t.string "created_by_id", null: false
    t.string "updated_by_id"
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
    t.datetime "created_at_utc", null: false
    t.datetime "updated_at_utc"
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

end
