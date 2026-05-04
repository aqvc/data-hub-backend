require "test_helper"

# User stories — Profile management
#
# As a logged-in user
# I want to update my own first/last name
# So that the app reflects my preferred display name
class ProfileManagementTest < ActionDispatch::IntegrationTest
  setup do
    @member = create_user!(
      email: "member@example.com",
      first_name: "Mick",
      last_name: "Member",
      password: "Password123!"
    )
    @member.add_role(:member)
  end

  # ---------------------------------------------------------------------------
  # updateProfile (Mutations::UpdateProfile)
  # ---------------------------------------------------------------------------

  test "P.1 updateProfile: updates first and last name" do
    login_as!("member@example.com", "Password123!")

    response = update_profile!(first_name: "Michael", last_name: "Memberson")

    assert_equal true, response.dig("data", "updateProfile", "success")
    @member.reload
    assert_equal "Michael", @member.first_name
    assert_equal "Memberson", @member.last_name
  end

  test "P.2 updateProfile: blank values are ignored (only present fields update)" do
    login_as!("member@example.com", "Password123!")
    original_last = @member.last_name

    update_profile!(first_name: "OnlyFirst", last_name: "")

    @member.reload
    assert_equal "OnlyFirst", @member.first_name
    assert_equal original_last, @member.last_name
  end

  test "P.3 updateProfile: omitting both arguments is a no-op success" do
    login_as!("member@example.com", "Password123!")
    original_first = @member.first_name
    original_last = @member.last_name

    response = update_profile!(first_name: nil, last_name: nil)

    assert_equal true, response.dig("data", "updateProfile", "success")
    @member.reload
    assert_equal original_first, @member.first_name
    assert_equal original_last, @member.last_name
  end

  test "P.4 updateProfile: updated_by_id is set to the caller's id" do
    login_as!("member@example.com", "Password123!")

    update_profile!(first_name: "Updated")

    @member.reload
    assert_equal @member.id, @member.updated_by_id
  end

  test "P.5 updateProfile: unauthenticated request is rejected" do
    response = update_profile!(first_name: "ShouldNotChange")

    refute_nil response["errors"]
    @member.reload
    refute_equal "ShouldNotChange", @member.first_name
  end

  private

  def create_user!(email:, first_name:, last_name:, password:)
    user = User.new(
      created_by_id: "seed-user",
      user_name: email,
      email: email,
      first_name: first_name,
      last_name: last_name,
      email_confirmed: true,
      security_stamp: SecureRandom.uuid,
      concurrency_stamp: SecureRandom.uuid,
      phone_number_confirmed: false,
      two_factor_enabled: false,
      lockout_enabled: true,
      access_failed_count: 0,
      password: password,
      password_confirmation: password
    )
    user.save!
    user.update_column(:created_by_id, user.id)
    user
  end

  def graphql(query, variables: nil)
    post "/graphql", params: { query: query, variables: variables }
    assert_response :success
    JSON.parse(response.body)
  end

  LOGIN_MUTATION = <<~GRAPHQL.freeze
    mutation($email: String!, $password: String!) {
      login(email: $email, password: $password) { authenticated userId roles }
    }
  GRAPHQL

  def login_as!(email, password)
    response = graphql(LOGIN_MUTATION, variables: { email: email, password: password })
    assert_equal true, response.dig("data", "login", "authenticated"), response.inspect
    response
  end

  UPDATE_PROFILE = <<~GRAPHQL.freeze
    mutation($firstName: String, $lastName: String) {
      updateProfile(firstName: $firstName, lastName: $lastName) { success }
    }
  GRAPHQL

  def update_profile!(first_name: nil, last_name: nil)
    graphql(UPDATE_PROFILE, variables: { firstName: first_name, lastName: last_name })
  end
end
