require "test_helper"

# User stories — Investor management (GraphQL surface)
#
# As a logged-in account manager / admin
# I want to search, filter, sort, paginate, export, create, update, qualify,
#   and delete investors and their related vehicles/strategies/contacts/entities,
# So that I can curate the database that drives the rest of the product.
#
# Coverage focuses on the *gaps* in graphql_api_test.rb (which is a happy-path
# smoke test). Edge cases here: pagination math, sort order, filter
# normalization, CSV column resolution, qualify side-effects, transactional
# proof-point persistence, not-found surfaces.
class InvestorManagementTest < ActionDispatch::IntegrationTest
  setup do
    @now = Time.current.utc.change(usec: 0)

    @admin = create_user!(email: "admin@example.com", first_name: "Ada", last_name: "Admin", password: "Password123!")
    @admin.add_role(:admin)

    @region = Region.create!(name: "Asia", code: "AS", description: "Asia", created_at_utc: @now)
    @country = Country.create!(region_id: @region.id, name: "Pakistan", iso_code: "PK", iso3code: "PAK", calling_code: "+92", created_at_utc: @now)

    @org = OrganizationProfile.create!(
      subdomain: "aqvc", company_name: "AQVC", company_legal_name: "AQVC Legal",
      created_by_id: @admin.id, created_at_utc: @now
    )

    login_as!("admin@example.com", "Password123!")
  end

  # ---------------------------------------------------------------------------
  # investorSearch — pagination
  # ---------------------------------------------------------------------------

  test "IS.1 search: pagination math returns correct hasNext / hasPrev / totalPages" do
    5.times { |i| create_investor!("Inv-#{i}") }

    page1 = run_search(page: 1, limit: 2)
    assert_equal 5, page1["total"]
    assert_equal 1, page1["page"]
    assert_equal 3, page1["totalPages"]
    assert_equal true, page1["hasNext"]
    assert_equal false, page1["hasPrev"]
    assert_equal 2, page1["data"].length

    page3 = run_search(page: 3, limit: 2)
    assert_equal 1, page3["data"].length
    assert_equal false, page3["hasNext"]
    assert_equal true, page3["hasPrev"]
  end

  test "IS.2 search: limit is clamped to 100 when caller requests more" do
    create_investor!("Alpha")

    payload = run_search(page: 1, limit: 9999)
    assert_equal 100, payload["limit"]
  end

  test "IS.3 search: limit defaults to 10 when caller passes 0 or negative" do
    payload = run_search(page: 1, limit: 0)
    assert_equal 10, payload["limit"]
  end

  test "IS.4 search: empty filter returns all investors" do
    create_investor!("Alpha")
    create_investor!("Beta")

    payload = run_search
    assert_equal 2, payload["total"]
  end

  # ---------------------------------------------------------------------------
  # investorSearch — name filter
  # ---------------------------------------------------------------------------

  test "IS.5 search: name filter is case-insensitive" do
    create_investor!("Alpha Capital")
    create_investor!("Beta Capital")

    payload = run_search(column_filter: { name: "ALPHA" })
    assert_equal 1, payload["total"]
    assert_equal "Alpha Capital", payload["data"][0]["name"]
  end

  test "IS.6 search: name filter matches investor name OR vehicle name OR strategy name" do
    inv_a = create_investor!("Quartz Capital")
    inv_b = create_investor!("Onyx Capital")
    create_vehicle!(inv_b, name: "Quartz Fund I") # vehicle name matches search term

    payload = run_search(column_filter: { name: "quartz" })
    ids = payload["data"].map { |row| row["id"] }
    assert_includes ids, inv_a.id, "should match by investor name"
    assert_includes ids, inv_b.id, "should match by vehicle name"
  end

  # ---------------------------------------------------------------------------
  # investorSearch — sort order
  # ---------------------------------------------------------------------------

  test "IS.7 search: default sort is by name ascending" do
    create_investor!("Charlie")
    create_investor!("Alpha")
    create_investor!("Bravo")

    payload = run_search
    names = payload["data"].map { |row| row["name"] }
    assert_equal ["Alpha", "Bravo", "Charlie"], names
  end

  test "IS.8 search: sort by updatedAtUtc desc places never-updated investors last (NULLS LAST)" do
    older = create_investor!("Older")
    older.update_columns(updated_at_utc: 5.days.ago)
    newer = create_investor!("Newer")
    newer.update_columns(updated_at_utc: 1.hour.ago)
    untouched = create_investor!("Untouched")
    untouched.update_columns(updated_at_utc: nil)

    payload = run_search(sort: [{ field: "updatedAtUtc", direction: "desc" }])
    names = payload["data"].map { |row| row["name"] }
    assert_equal "Newer", names.first
    assert_equal "Untouched", names.last
  end

  # ---------------------------------------------------------------------------
  # exportInvestorsByFilters / ByIds
  # ---------------------------------------------------------------------------

  test "IE.1 export: respects requested columns and omits the rest" do
    create_investor!("Alpha", website_url: "alpha.example")

    csv = run_export_by_filters(columns: ["name"])
    header_row = csv.lines.first.strip
    assert_equal "name", header_row
    refute_includes csv, "alpha.example"
  end

  test "IE.2 export: dropping pseudo-columns 'select' and 'actions' from caller list" do
    create_investor!("Alpha")

    csv = run_export_by_filters(columns: ["select", "name", "actions"])
    header_row = csv.lines.first.strip
    assert_equal "name", header_row
  end

  test "IE.3 export: empty columns list falls back to default columns" do
    create_investor!("Alpha")

    csv = run_export_by_filters(columns: [])
    header_row = csv.lines.first.strip
    %w[name websiteUrl investorType].each do |col|
      assert_includes header_row, col
    end
  end

  test "IE.4 export: by-ids honours selectedIds and ignores filters" do
    inv_a = create_investor!("Alpha")
    create_investor!("Beta")

    csv = run_export_by_ids(selected_ids: [inv_a.id], columns: ["name"])
    assert_includes csv, "Alpha"
    refute_includes csv, "Beta"
  end

  # ---------------------------------------------------------------------------
  # investor (single fetch)
  # ---------------------------------------------------------------------------

  test "IC.1 investor: not found returns Investors.NotFound (404)" do
    response = graphql("query { investor(id: \"99999999\") }")
    error = response.fetch("errors").first
    assert_equal "Investors.NotFound", error.dig("extensions", "code")
    assert_equal 404, error.dig("extensions", "status")
  end

  # ---------------------------------------------------------------------------
  # createInvestor / updateInvestor
  # ---------------------------------------------------------------------------

  test "IC.2 createInvestor: produces a record owned by the caller" do
    response = graphql("mutation { createInvestor { id } }")
    investor = Investor.find(response.dig("data", "createInvestor", "id"))

    assert_equal @admin.id, investor.created_by_id
  end

  test "IC.3 updateInvestor: writes attributes and persists proofPoints atomically" do
    investor = create_investor!("Alpha")

    response = run_update_investor(
      id: investor.id,
      investor_attrs: { websiteUrl: "https://updated.example" },
      proof_points: [
        { fieldId: "websiteUrl", proofType: "manual", sourceName: "audit" }
      ]
    )

    assert_equal true, response.dig("data", "updateInvestor", "success")
    investor.reload
    assert_equal "https://updated.example", investor.website_url
    assert_equal 1, ProofLedger.where(investor_id: investor.id, field_id: "websiteUrl").count
  end

  test "IC.4 updateInvestor: proof points missing field_id are skipped, others persist" do
    investor = create_investor!("Alpha")

    run_update_investor(
      id: investor.id,
      investor_attrs: {},
      proof_points: [
        { fieldId: "", proofType: "manual" },
        { fieldId: "name", proofType: "manual" }
      ]
    )

    assert_equal 1, ProofLedger.where(investor_id: investor.id).count
    assert_equal "name", ProofLedger.where(investor_id: investor.id).first.field_id
  end

  # ---------------------------------------------------------------------------
  # qualifyInvestor
  # ---------------------------------------------------------------------------

  test "IC.5 qualifyInvestor: flips the boolean and stamps qualified_at/by" do
    investor = create_investor!("Alpha")
    refute investor.qualified

    response = run_qualify(id: investor.id, qualified: true)

    assert_equal true, response.dig("data", "qualifyInvestor", "success")
    investor.reload
    assert_equal true, investor.qualified
    refute_nil investor.qualified_at_utc
    assert_equal @admin.id, investor.qualified_by_id
  end

  test "IC.6 qualifyInvestor: idempotent re-qualify (true -> true) is a success" do
    investor = create_investor!("Alpha")
    investor.update_columns(qualified: true, qualified_at_utc: 1.day.ago, qualified_by_id: @admin.id)

    response = run_qualify(id: investor.id, qualified: true)
    assert_equal true, response.dig("data", "qualifyInvestor", "success")
  end

  test "IC.7 qualifyInvestor: setting back to false un-qualifies" do
    investor = create_investor!("Alpha")
    investor.update_columns(qualified: true, qualified_at_utc: 1.day.ago, qualified_by_id: @admin.id)

    run_qualify(id: investor.id, qualified: false)
    investor.reload
    assert_equal false, investor.qualified
  end

  # ---------------------------------------------------------------------------
  # Authorization
  # ---------------------------------------------------------------------------

  test "IC.8 unauthenticated investor query is rejected" do
    delete_session_cookies!

    response = graphql("query { investor(id: \"abc\") }")
    refute_nil response["errors"]
  end

  private

  # --- helpers --------------------------------------------------------------

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

  def create_investor!(name, type: "family_office", website_url: nil)
    Investor.create!(
      name: name,
      type: type,
      website_url: website_url,
      qualified: false,
      organization_profile_id: @org.id,
      created_by_id: @admin.id,
      created_at_utc: @now
    )
  end

  def create_vehicle!(investor, name:)
    InvestmentVehicle.create!(
      investor_id: investor.id,
      name: name,
      created_by_id: @admin.id,
      created_at_utc: @now
    )
  end

  def graphql(query, variables: nil)
    post "/graphql", params: { query: query, variables: variables }
    assert_response :success
    JSON.parse(response.body)
  end

  def delete_session_cookies!
    cookies.each_key { |k| cookies.delete(k) }
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

  SEARCH = <<~GRAPHQL.freeze
    query($page: Int, $limit: Int, $columnFilter: JSON, $sort: [SortInput!]) {
      investorSearch(page: $page, limit: $limit, columnFilter: $columnFilter, sort: $sort)
    }
  GRAPHQL

  def run_search(page: 1, limit: 10, column_filter: {}, sort: [])
    response = graphql(SEARCH, variables: {
      page: page,
      limit: limit,
      columnFilter: column_filter,
      sort: sort
    })
    response.dig("data", "investorSearch")
  end

  EXPORT_BY_FILTERS = <<~GRAPHQL.freeze
    query($columns: [String!]) {
      exportInvestorsByFilters(columns: $columns)
    }
  GRAPHQL

  def run_export_by_filters(columns:)
    response = graphql(EXPORT_BY_FILTERS, variables: { columns: columns })
    response.dig("data", "exportInvestorsByFilters")
  end

  EXPORT_BY_IDS = <<~GRAPHQL.freeze
    query($selectedIds: [ID!], $columns: [String!]) {
      exportInvestorsByIds(selectedIds: $selectedIds, columns: $columns)
    }
  GRAPHQL

  def run_export_by_ids(selected_ids:, columns:)
    response = graphql(EXPORT_BY_IDS, variables: { selectedIds: selected_ids, columns: columns })
    response.dig("data", "exportInvestorsByIds")
  end

  UPDATE_INVESTOR = <<~GRAPHQL.freeze
    mutation($id: ID!, $investor: JSON, $proofPoints: [JSON!]) {
      updateInvestor(id: $id, investor: $investor, proofPoints: $proofPoints) { success }
    }
  GRAPHQL

  def run_update_investor(id:, investor_attrs:, proof_points: [])
    graphql(UPDATE_INVESTOR, variables: { id: id, investor: investor_attrs, proofPoints: proof_points })
  end

  QUALIFY = <<~GRAPHQL.freeze
    mutation($id: ID!, $qualified: Boolean!) {
      qualifyInvestor(id: $id, qualified: $qualified) { success }
    }
  GRAPHQL

  def run_qualify(id:, qualified:)
    graphql(QUALIFY, variables: { id: id, qualified: qualified })
  end
end
