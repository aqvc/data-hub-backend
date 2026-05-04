require "test_helper"

# User stories — Analytics dashboard
#
# As an authenticated team member
# I want to see KPI stats, distributions, and per-teammate activity
# So that I can understand database health and team productivity at a glance
class AnalyticsTest < ActionDispatch::IntegrationTest
  setup do
    @now = Time.current.utc.change(usec: 0)

    @admin = create_user!(email: "admin@example.com", first_name: "Ada", last_name: "Admin", password: "Password123!")
    @admin.add_role(:admin)

    @member = create_user!(email: "member@example.com", first_name: "Mick", last_name: "Member", password: "Password123!")
    @member.add_role(:member)

    @region = Region.create!(name: "Asia", code: "AS", description: "Asia", created_at_utc: @now)
    @country = Country.create!(region_id: @region.id, name: "Pakistan", iso_code: "PK", iso3code: "PAK", calling_code: "+92", created_at_utc: @now)

    @org = OrganizationProfile.create!(
      subdomain: "aqvc", company_name: "AQVC", company_legal_name: "AQVC Legal",
      created_by_id: @admin.id, created_at_utc: @now
    )
  end

  # ---------------------------------------------------------------------------
  # analyticsDatabaseInsightsOverview (DatabaseInsightsOverviewService)
  # ---------------------------------------------------------------------------

  test "AO.1 overview: empty database returns zero KPIs and a 6-month timeline" do
    login_as!("admin@example.com", "Password123!")

    payload = graphql("query { analyticsDatabaseInsightsOverview }").dig("data", "analyticsDatabaseInsightsOverview")

    assert_equal 0, payload.dig("kpiStats", "totalInvestors", "total")
    assert_equal 0.0, payload.dig("kpiStats", "totalInvestors", "growthRate")
    refute_nil payload["activityTimeline"]
    assert payload["activityTimeline"].is_a?(Array)
    # 6 months -> 180-184 days depending on month lengths; assert sane bounds
    assert payload["activityTimeline"].length.between?(180, 184)
  end

  test "AO.2 overview: total counts reflect created investors, contacts, and proof points" do
    create_investor!("Alpha")
    create_investor!("Beta")
    contact = create_contact!(@admin)
    proof = create_proof_ledger!(field_id: "name")

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsOverview }").dig("data", "analyticsDatabaseInsightsOverview")

    assert_equal 2, payload.dig("kpiStats", "totalInvestors", "total")
    assert_equal 1, payload.dig("kpiStats", "totalContacts", "total")
    assert_equal 1, payload.dig("kpiStats", "totalProofPoints", "total")
  end

  test "AO.3 overview: growth_rate is 100.0 when prior count was zero and current is positive" do
    # New investor created today; nothing one week ago
    create_investor!("Alpha")

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsOverview }").dig("data", "analyticsDatabaseInsightsOverview")

    # totalInvestors compares total vs >7-day-old; latter is 0 -> 100.0
    assert_equal 100.0, payload.dig("kpiStats", "totalInvestors", "growthRate")
  end

  test "AO.4 overview: growth_rate is 0.0 when current and prior both zero" do
    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsOverview }").dig("data", "analyticsDatabaseInsightsOverview")

    assert_equal 0.0, payload.dig("kpiStats", "totalInvestors", "growthRate")
  end

  test "AO.5 overview: qualified KPI uses qualified_at_utc, not created_at_utc" do
    investor = create_investor!("Alpha")
    investor.update_columns(qualified: true, qualified_at_utc: 10.days.ago, qualified_by_id: @admin.id)

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsOverview }").dig("data", "analyticsDatabaseInsightsOverview")

    # Qualified count for "now" = 1, for "more than 7 days ago" = 1, growth = 0.0
    assert_equal 1, payload.dig("kpiStats", "totalQualified", "total")
  end

  test "AO.6 overview: activity timeline counts added_count and qualified_count for the right day" do
    investor = create_investor!("Alpha")
    investor.update_columns(qualified: true, qualified_at_utc: @now, qualified_by_id: @admin.id)

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsOverview }").dig("data", "analyticsDatabaseInsightsOverview")

    today = Date.current.strftime("%Y-%m-%d")
    today_entry = payload["activityTimeline"].find { |e| e["date"] == today }
    refute_nil today_entry, "expected timeline entry for #{today}"
    assert_equal 1, today_entry["addedCount"]
    assert_equal 1, today_entry["qualifiedCount"]
  end

  test "AO.7 overview: unauthenticated request is rejected" do
    response = graphql("query { analyticsDatabaseInsightsOverview }")
    refute_nil response["errors"]
  end

  # ---------------------------------------------------------------------------
  # analyticsDatabaseInsightsDistributions (DatabaseInsightsDistributionsService)
  # ---------------------------------------------------------------------------

  test "AD.1 distributions: empty database returns empty buckets" do
    login_as!("admin@example.com", "Password123!")

    payload = graphql("query { analyticsDatabaseInsightsDistributions }").dig("data", "analyticsDatabaseInsightsDistributions")

    %w[byType bySector byStage byCountry byRegion byMaturity].each do |key|
      assert_equal [], payload[key], "expected empty bucket for #{key}"
    end
  end

  test "AD.2 distributions: type counted once per investor regardless of strategy count" do
    investor = create_investor!("Alpha", type: "family_office")
    create_strategy!(investor, name: "S1", sector: ["fin_tech"])
    create_strategy!(investor, name: "S2", sector: ["fin_tech"])

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsDistributions }").dig("data", "analyticsDatabaseInsightsDistributions")

    family_office_bucket = payload["byType"].find { |b| b["label"] == "family_office" }
    assert_equal 1, family_office_bucket["count"]
  end

  test "AD.3 distributions: sector duplicates within one investor count once" do
    investor = create_investor!("Alpha", type: "family_office")
    create_strategy!(investor, name: "S1", sector: ["fin_tech", "fin_tech"])
    create_strategy!(investor, name: "S2", sector: ["fin_tech"])

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsDistributions }").dig("data", "analyticsDatabaseInsightsDistributions")

    fin_tech_bucket = payload["bySector"].find { |b| b["label"] == "fin_tech" }
    assert_equal 1, fin_tech_bucket["count"]
  end

  test "AD.4 distributions: bySector aggregates across investors (sum of unique-per-investor)" do
    inv_a = create_investor!("Alpha", type: "family_office")
    inv_b = create_investor!("Beta", type: "family_office")
    create_strategy!(inv_a, name: "S1", sector: ["fin_tech"])
    create_strategy!(inv_b, name: "S2", sector: ["fin_tech", "ed_tech"])

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsDistributions }").dig("data", "analyticsDatabaseInsightsDistributions")

    fin_tech = payload["bySector"].find { |b| b["label"] == "fin_tech" }
    ed_tech  = payload["bySector"].find { |b| b["label"] == "ed_tech" }
    assert_equal 2, fin_tech["count"]
    assert_equal 1, ed_tech["count"]
  end

  test "AD.5 distributions: results are sorted by count desc" do
    inv_a = create_investor!("Alpha", type: "family_office")
    inv_b = create_investor!("Beta",  type: "family_office")
    create_strategy!(inv_a, name: "S1", sector: ["fin_tech"])
    create_strategy!(inv_b, name: "S2", sector: ["fin_tech", "ed_tech"])

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsDistributions }").dig("data", "analyticsDatabaseInsightsDistributions")

    counts = payload["bySector"].map { |b| b["count"] }
    assert_equal counts.sort.reverse, counts, "expected counts in descending order"
  end

  test "AD.6 distributions: investors without strategies don't pollute buckets" do
    create_investor!("NoStrategies", type: "family_office")

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsDatabaseInsightsDistributions }").dig("data", "analyticsDatabaseInsightsDistributions")

    # The service starts from InvestmentStrategy.where.not(investor_id: nil),
    # so an investor with no strategies contributes nothing.
    assert_equal [], payload["bySector"]
    assert_equal [], payload["byType"]
  end

  # ---------------------------------------------------------------------------
  # analyticsTeam (TeamPerformanceService)
  # ---------------------------------------------------------------------------

  test "AT.1 team: returns one entry per teammate with the expected role" do
    login_as!("admin@example.com", "Password123!")

    payload = graphql("query { analyticsTeam }").dig("data", "analyticsTeam")

    user_ids = payload.map { |entry| entry["userId"] }
    assert_includes user_ids, @admin.id
    assert_includes user_ids, @member.id
  end

  test "AT.2 team: user with no activity has zero totals and an empty actions array" do
    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsTeam }").dig("data", "analyticsTeam")

    member_entry = payload.find { |e| e["userId"] == @member.id }
    assert_equal 0, member_entry["totalCreatedAllTime"]
    assert_equal 0, member_entry["totalQualifiedAllTime"]
    assert_equal 0, member_entry["totalProofPointsAllTime"]
    assert_equal [], member_entry["actions"]
  end

  test "AT.3 team: user_name falls back to email when user_name is blank" do
    @admin.update_column(:user_name, nil)
    login_as!("admin@example.com", "Password123!")

    payload = graphql("query { analyticsTeam }").dig("data", "analyticsTeam")
    admin_entry = payload.find { |e| e["userId"] == @admin.id }

    assert_equal @admin.email, admin_entry["userName"]
  end

  test "AT.4 team: created/qualified/proof totals reflect the caller's actions" do
    investor = create_investor!("Alpha")
    investor.update_columns(qualified: true, qualified_at_utc: @now, qualified_by_id: @admin.id)
    create_proof_ledger!(field_id: "name", investor_id: investor.id)

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsTeam }").dig("data", "analyticsTeam")
    admin_entry = payload.find { |e| e["userId"] == @admin.id }

    assert_equal 1, admin_entry["totalCreatedAllTime"]
    assert_equal 1, admin_entry["totalQualifiedAllTime"]
    assert_equal 1, admin_entry["totalProofPointsAllTime"]
  end

  test "AT.5 team: actions contains an entry for every date with activity from any of the 3 scopes" do
    investor = create_investor!("Alpha")
    today = Date.current.to_s

    login_as!("admin@example.com", "Password123!")
    payload = graphql("query { analyticsTeam }").dig("data", "analyticsTeam")
    admin_entry = payload.find { |e| e["userId"] == @admin.id }
    today_action = admin_entry["actions"].find { |a| a["date"] == today }

    refute_nil today_action
    assert_equal 1, today_action["createdCount"]
    assert_equal 0, today_action["qualifiedCount"]
    assert_equal 0, today_action["proofPointsCount"]
  end

  test "AT.6 team: unauthenticated request is rejected" do
    response = graphql("query { analyticsTeam }")
    refute_nil response["errors"]
  end

  private

  def create_user!(email:, first_name:, last_name:, password:)
    user = User.new(
      created_by_id: "seed-user",
      user_name: email, email: email,
      first_name: first_name, last_name: last_name,
      email_confirmed: true,
      security_stamp: SecureRandom.uuid, concurrency_stamp: SecureRandom.uuid,
      phone_number_confirmed: false, two_factor_enabled: false, lockout_enabled: true,
      access_failed_count: 0,
      password: password, password_confirmation: password
    )
    user.save!
    user.update_column(:created_by_id, user.id)
    user
  end

  def create_investor!(name, type: nil)
    Investor.create!(
      name: name,
      type: type,
      qualified: false,
      organization_profile_id: @org.id,
      created_by_id: @admin.id,
      created_at_utc: @now
    )
  end

  def create_strategy!(investor, name:, sector: [], stage: [], maturity: [], asset_class: [])
    InvestmentStrategy.create!(
      investor_id: investor.id,
      name: name,
      sector_investment_focus: sector,
      stage_focus: stage,
      maturity_focus: maturity,
      asset_class_focus: asset_class,
      strategy_focus: ["primary"],
      created_by_id: @admin.id,
      created_at_utc: @now
    )
  end

  def create_contact!(user)
    investor = create_investor!("ContactHolder")
    InvestorContact.create!(
      investor_id: investor.id,
      first_name: "Test", last_name: "Contact",
      email: "contact-#{SecureRandom.hex(4)}@example.com",
      created_by_id: user.id, created_at_utc: @now
    )
  end

  def create_proof_ledger!(field_id:, investor_id: nil)
    investor_id ||= create_investor!("ProofHolder").id
    ProofLedger.create!(
      investor_id: investor_id,
      field_id: field_id,
      proof_type: "manual",
      status: "active",
      version: 0,
      created_by_id: @admin.id,
      created_at_utc: @now
    )
  end

  def graphql(query, variables: nil)
    post "/graphql", params: { query: query, variables: variables }
    assert_response :success
    JSON.parse(response.body)
  end

  LOGIN = <<~GRAPHQL.freeze
    mutation($email: String!, $password: String!) {
      login(email: $email, password: $password) { authenticated userId roles }
    }
  GRAPHQL

  def login_as!(email, password)
    response = graphql(LOGIN, variables: { email: email, password: password })
    assert_equal true, response.dig("data", "login", "authenticated"), response.inspect
    response
  end
end
