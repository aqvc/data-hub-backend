require "test_helper"

class AuthAndInvitesTest < ActionDispatch::IntegrationTest
  setup do
    @now = Time.current.utc.change(usec: 0)

    @admin = create_user!(
      email: "admin@example.com",
      first_name: "Ada",
      last_name: "Admin",
      password: "Password123!"
    )
    @admin.add_role(:admin)

    @superadmin = create_user!(
      email: "super@example.com",
      first_name: "Sara",
      last_name: "Super",
      password: "Password123!"
    )
    @superadmin.add_role(:superadmin)

    @member = create_user!(
      email: "member@example.com",
      first_name: "Mick",
      last_name: "Member",
      password: "Password123!"
    )
    @member.add_role(:member)
  end

  # ---------------------------------------------------------------------------
  # Login (Mutations::Login)
  # ---------------------------------------------------------------------------

  test "1.1 login: happy path returns authenticated payload and establishes session" do
    response = login_as!("member@example.com", "Password123!")

    assert_equal true, response.dig("data", "login", "authenticated")
    assert_equal @member.id, response.dig("data", "login", "userId")
    assert_includes response.dig("data", "login", "roles"), "member"
  end

  test "1.2 login: unknown email returns Users.NotFoundByEmail (404)" do
    response = run_login_mutation("ghost@example.com", "anything")

    error = response.fetch("errors").first
    assert_equal "Users.NotFoundByEmail", error.dig("extensions", "code")
    assert_equal 404, error.dig("extensions", "status")
  end

  test "1.3 login: wrong password returns Users.Unauthorized (401)" do
    response = run_login_mutation("member@example.com", "WrongPassword!")

    error = response.fetch("errors").first
    assert_equal "Users.Unauthorized", error.dig("extensions", "code")
    assert_equal 401, error.dig("extensions", "status")
  end

  test "1.4 login: previous session is reset before new id is written" do
    login_as!("admin@example.com", "Password123!")
    # Switch to a different user; admin's session id must not leak through.
    response = login_as!("member@example.com", "Password123!")

    assert_equal @member.id, response.dig("data", "login", "userId")
  end

  test "1.5 login: empty email or password is rejected by GraphQL argument validation" do
    response = run_login_mutation("", "")

    refute_nil response["errors"]
  end

  test "1.6 login: multi-role user returns all role names" do
    @member.add_role(:data_manager)

    response = login_as!("member@example.com", "Password123!")

    roles = response.dig("data", "login", "roles")
    assert_includes roles, "member"
    assert_includes roles, "data_manager"
  end

  # ---------------------------------------------------------------------------
  # Logout (Mutations::Logout)
  # ---------------------------------------------------------------------------

  test "1.7 logout: authenticated session ends successfully" do
    login_as!("admin@example.com", "Password123!")

    logout_response = graphql("mutation { logout { success } }")

    assert_equal true, logout_response.dig("data", "logout", "success")
  end

  test "1.8 logout: unauthenticated request is rejected with Auth.MissingSession" do
    logout_response = graphql("mutation { logout { success } }")

    error = logout_response.fetch("errors").first
    assert_equal "Auth.MissingSession", error.dig("extensions", "code")
  end

  # ---------------------------------------------------------------------------
  # Send invitation (Mutations::SendInvitation)
  # ---------------------------------------------------------------------------

  test "2a.1 sendInvitation: admin invites a brand-new email" do
    login_as!("admin@example.com", "Password123!")

    response = send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "New", role_name: "member")

    payload = response.dig("data", "sendInvitation")
    assert_equal "nina@example.com", payload["email"]

    user = User.find(payload["id"])
    assert_equal "Nina", user.first_name
    assert_equal false, user.email_confirmed
    assert_includes user.role_names, "member"
    refute_nil user.invitation_token
  end

  test "2a.2 sendInvitation: email is trimmed and downcased before persistence" do
    login_as!("admin@example.com", "Password123!")

    response = send_invitation!(
      email: "  NINA@Example.COM  ",
      first_name: "Nina",
      last_name: "New",
      role_name: "member"
    )

    user = User.find(response.dig("data", "sendInvitation", "id"))
    assert_equal "nina@example.com", user.email
  end

  test "2a.3 sendInvitation: rejects when target already accepted an invite" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "New", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    invitee.update_columns(invitation_accepted_at: @now)

    response = send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "New", role_name: "member")

    error = response.fetch("errors").first
    assert_equal "Invitations.EmailTaken", error.dig("extensions", "code")
    assert_equal 409, error.dig("extensions", "status")
  end

  test "2a.4 sendInvitation: rejects when email belongs to a non-invited (seeded) user" do
    login_as!("admin@example.com", "Password123!")

    response = send_invitation!(email: "admin@example.com", first_name: "Ada", last_name: "Admin", role_name: "member")

    error = response.fetch("errors").first
    assert_equal "Invitations.EmailTaken", error.dig("extensions", "code")
  end

  test "2a.5 sendInvitation: pending invite — re-invite updates name and reissues token without duplicating user" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Old", last_name: "Name", role_name: "member")
    original_id = User.find_by(email: "nina@example.com").id

    response = send_invitation!(email: "nina@example.com", first_name: "Updated", last_name: "Name", role_name: "member")

    user = User.find(response.dig("data", "sendInvitation", "id"))
    assert_equal original_id, user.id
    assert_equal "Updated", user.first_name
  end

  test "2a.6 sendInvitation: invalid email format is rejected" do
    login_as!("admin@example.com", "Password123!")

    response = send_invitation!(email: "not-an-email", first_name: "X", last_name: "Y", role_name: "member")

    error = response.fetch("errors").first
    assert_equal "Invitations.InvalidEmail", error.dig("extensions", "code")
    assert_equal 400, error.dig("extensions", "status")
  end

  test "2a.7 sendInvitation: invalid role is rejected with allowed-roles message" do
    login_as!("admin@example.com", "Password123!")

    response = send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "wizard")

    error = response.fetch("errors").first
    assert_equal "Invitations.InvalidRole", error.dig("extensions", "code")
    assert_match(/admin|account_manager|data_manager|member/, error.dig("extensions", "detail"))
  end

  test "2a.8 sendInvitation: non-admin caller is forbidden" do
    login_as!("member@example.com", "Password123!")

    response = send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")

    refute_nil response["errors"]
    assert_nil User.find_by(email: "nina@example.com")
  end

  # ---------------------------------------------------------------------------
  # Resend invitation (Mutations::ResendInvitation)
  # ---------------------------------------------------------------------------

  test "2b.1 resendInvitation: pending invite is resent successfully" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    original_token = invitee.invitation_token

    response = resend_invitation!(invitee.id)

    assert_equal true, response.dig("data", "resendInvitation", "success")
    invitee.reload
    refute_equal original_token, invitee.invitation_token
  end

  test "2b.2 resendInvitation: returns Users.NotFound for unknown id" do
    login_as!("admin@example.com", "Password123!")

    response = resend_invitation!(0)

    error = response.fetch("errors").first
    assert_equal "Users.NotFound", error.dig("extensions", "code")
  end

  test "2b.3 resendInvitation: rejects when user has already accepted" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    invitee.update_columns(invitation_accepted_at: @now)

    response = resend_invitation!(invitee.id)

    error = response.fetch("errors").first
    assert_equal "Invitations.NotPending", error.dig("extensions", "code")
  end

  test "2b.4 resendInvitation: rejects when target user was not invited" do
    login_as!("admin@example.com", "Password123!")

    response = resend_invitation!(@member.id)

    error = response.fetch("errors").first
    assert_equal "Invitations.NotPending", error.dig("extensions", "code")
  end

  test "2b.5 resendInvitation: non-admin caller is forbidden" do
    login_as!("member@example.com", "Password123!")

    response = resend_invitation!(@admin.id)

    refute_nil response["errors"]
  end

  # ---------------------------------------------------------------------------
  # Accept invitation (Mutations::AcceptInvitation)
  # ---------------------------------------------------------------------------

  test "2c.1 acceptInvitation: happy path activates user and establishes session" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    raw_token = invitee.send(:set_reset_password_token) # Devise re-issues a fresh token under the hood; capture via raw query helper
    raw_token = raw_invitation_token(invitee)

    payload = run_accept_invitation(
      token: raw_token,
      password: "NewPass123!",
      password_confirmation: "NewPass123!",
      first_name: "Nina",
      last_name: "Newish"
    )

    assert_equal true, payload.dig("data", "acceptInvitation", "authenticated")
    invitee.reload
    assert_equal true, invitee.email_confirmed
    assert_equal "Newish", invitee.last_name
    refute_nil invitee.invitation_accepted_at
  end

  test "2c.2 acceptInvitation: invalid token is rejected" do
    response = run_accept_invitation(
      token: "this-is-not-a-valid-token",
      password: "NewPass123!",
      password_confirmation: "NewPass123!",
      first_name: "Nina",
      last_name: "N"
    )

    error = response.fetch("errors").first
    assert_equal "Invitations.InvalidToken", error.dig("extensions", "code")
  end

  test "2c.3 acceptInvitation: password/confirmation mismatch is rejected and not persisted" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    raw_token = raw_invitation_token(invitee)
    original_password_hash = invitee.encrypted_password

    response = run_accept_invitation(
      token: raw_token,
      password: "NewPass123!",
      password_confirmation: "DifferentPass456!",
      first_name: "Nina",
      last_name: "N"
    )

    error = response.fetch("errors").first
    assert_equal "Invitations.PasswordMismatch", error.dig("extensions", "code")
    invitee.reload
    assert_equal original_password_hash, invitee.encrypted_password
  end

  test "2c.4 acceptInvitation: password failing Devise validation surfaces as AcceptFailed" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    raw_token = raw_invitation_token(invitee)

    response = run_accept_invitation(
      token: raw_token,
      password: "x",
      password_confirmation: "x",
      first_name: "Nina",
      last_name: "N"
    )

    error = response.fetch("errors").first
    assert_equal "Invitations.AcceptFailed", error.dig("extensions", "code")
    invitee.reload
    assert_nil invitee.invitation_accepted_at
  end

  test "2c.5 acceptInvitation: token cannot be re-used after acceptance" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    raw_token = raw_invitation_token(invitee)

    run_accept_invitation(
      token: raw_token,
      password: "NewPass123!",
      password_confirmation: "NewPass123!",
      first_name: "Nina",
      last_name: "N"
    )

    response = run_accept_invitation(
      token: raw_token,
      password: "Another123!",
      password_confirmation: "Another123!",
      first_name: "Nina",
      last_name: "N"
    )

    error = response.fetch("errors").first
    assert_equal "Invitations.InvalidToken", error.dig("extensions", "code")
  end

  # ---------------------------------------------------------------------------
  # Update user (Mutations::UpdateUser)
  # ---------------------------------------------------------------------------

  test "2d.1 updateUser: admin updates a member's name and role" do
    login_as!("admin@example.com", "Password123!")

    response = update_user!(id: @member.id, first_name: "Mickey", last_name: "M2", role_name: "data_manager")

    assert_equal true, response.dig("data", "updateUser", "success")
    @member.reload
    assert_equal "Mickey", @member.first_name
    assert_equal "M2", @member.last_name
    refute_includes @member.role_names, "member"
    assert_includes @member.role_names, "data_manager"
    assert_equal @admin.id, @member.updated_by_id
  end

  test "2d.2 updateUser: partial update only changes provided fields" do
    login_as!("admin@example.com", "Password123!")
    original_last = @member.last_name
    original_roles = @member.role_names

    update_user!(id: @member.id, first_name: "OnlyFirst", last_name: nil, role_name: nil)

    @member.reload
    assert_equal "OnlyFirst", @member.first_name
    assert_equal original_last, @member.last_name
    assert_equal original_roles.sort, @member.role_names.sort
  end

  test "2d.3 updateUser: invalid role is rejected" do
    login_as!("admin@example.com", "Password123!")

    response = update_user!(id: @member.id, role_name: "wizard")

    error = response.fetch("errors").first
    assert_equal "Users.InvalidRole", error.dig("extensions", "code")
  end

  test "2d.4 updateUser: admin caller cannot modify another admin (Forbidden)" do
    login_as!("admin@example.com", "Password123!")
    target_admin = create_user!(email: "second-admin@example.com", first_name: "Two", last_name: "Admin", password: "Password123!")
    target_admin.add_role(:admin)

    response = update_user!(id: target_admin.id, first_name: "ShouldNotChange")

    error = response.fetch("errors").first
    assert_equal "Users.Forbidden", error.dig("extensions", "code")
    target_admin.reload
    refute_equal "ShouldNotChange", target_admin.first_name
  end

  test "2d.5 updateUser: superadmin can modify another admin" do
    login_as!("super@example.com", "Password123!")
    target_admin = create_user!(email: "second-admin@example.com", first_name: "Two", last_name: "Admin", password: "Password123!")
    target_admin.add_role(:admin)

    response = update_user!(id: target_admin.id, first_name: "Renamed")

    assert_equal true, response.dig("data", "updateUser", "success")
    target_admin.reload
    assert_equal "Renamed", target_admin.first_name
  end

  test "2d.6 updateUser: target id not found" do
    login_as!("admin@example.com", "Password123!")

    response = update_user!(id: 0, first_name: "X")

    error = response.fetch("errors").first
    assert_equal "Users.NotFound", error.dig("extensions", "code")
  end

  # ---------------------------------------------------------------------------
  # Delete user (Mutations::DeleteUser)
  # ---------------------------------------------------------------------------

  test "2e.1 deleteUser: admin deletes a member" do
    login_as!("admin@example.com", "Password123!")

    response = delete_user!(@member.id)

    assert_equal true, response.dig("data", "deleteUser", "success")
    assert_nil User.find_by(id: @member.id)
  end

  test "2e.2 deleteUser: caller cannot delete themselves" do
    login_as!("admin@example.com", "Password123!")

    response = delete_user!(@admin.id)

    error = response.fetch("errors").first
    assert_equal "Users.CannotDeleteSelf", error.dig("extensions", "code")
    refute_nil User.find_by(id: @admin.id)
  end

  test "2e.3 deleteUser: admin caller cannot delete another admin" do
    login_as!("admin@example.com", "Password123!")
    target_admin = create_user!(email: "second-admin@example.com", first_name: "Two", last_name: "Admin", password: "Password123!")
    target_admin.add_role(:admin)

    response = delete_user!(target_admin.id)

    error = response.fetch("errors").first
    assert_equal "Users.Forbidden", error.dig("extensions", "code")
    refute_nil User.find_by(id: target_admin.id)
  end

  test "2e.4 deleteUser: superadmin can delete an admin" do
    login_as!("super@example.com", "Password123!")
    target_admin = create_user!(email: "second-admin@example.com", first_name: "Two", last_name: "Admin", password: "Password123!")
    target_admin.add_role(:admin)

    response = delete_user!(target_admin.id)

    assert_equal true, response.dig("data", "deleteUser", "success")
    assert_nil User.find_by(id: target_admin.id)
  end

  test "2e.5 deleteUser: unknown id returns Users.NotFound" do
    login_as!("admin@example.com", "Password123!")

    response = delete_user!(0)

    error = response.fetch("errors").first
    assert_equal "Users.NotFound", error.dig("extensions", "code")
  end

  # ---------------------------------------------------------------------------
  # Invitation lookup (query.invitationByToken)
  # ---------------------------------------------------------------------------

  test "2f.1 invitationByToken: valid token returns redacted user info" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    raw_token = raw_invitation_token(invitee)

    # Deliberately not authenticated — invitee opening the link.
    reset_session_cookies!
    response = run_invitation_by_token_query(raw_token)

    payload = response.dig("data", "invitationByToken")
    assert_equal "nina@example.com", payload["email"]
    assert_equal "Nina", payload["firstName"]
    assert_equal true, payload["invitationValid"]
  end

  test "2f.2 invitationByToken: unknown token returns null" do
    response = run_invitation_by_token_query("nonsense")

    assert_nil response.dig("data", "invitationByToken")
  end

  # ---------------------------------------------------------------------------
  # Create account manager (Mutations::CreateAccountManager)
  # ---------------------------------------------------------------------------

  test "3a.1 createAccountManager: happy path with provided password" do
    login_as!("admin@example.com", "Password123!")

    response = create_account_manager!(
      email: "manager@example.com",
      password: "ChosenPass1!",
      first_name: "Mary",
      last_name: "Manager"
    )

    user = User.find(response.dig("data", "createAccountManager", "id"))
    assert_equal "manager@example.com", user.email
    assert_equal true, user.email_confirmed
    assert_includes user.role_names, "account_manager"
    assert_equal true, user.valid_password?("ChosenPass1!")
  end

  test "3a.2 createAccountManager: empty password defaults to Password123!" do
    login_as!("admin@example.com", "Password123!")

    response = create_account_manager!(
      email: "manager@example.com",
      password: "",
      first_name: "Mary",
      last_name: "Manager"
    )

    user = User.find(response.dig("data", "createAccountManager", "id"))
    assert_equal true, user.valid_password?("Password123!")
  end

  test "3a.3 createAccountManager: invalid email format is rejected" do
    login_as!("admin@example.com", "Password123!")

    response = create_account_manager!(
      email: "nope",
      password: "Password123!",
      first_name: "X",
      last_name: "Y"
    )

    error = response.fetch("errors").first
    assert_equal "Users.RegistrationFailed", error.dig("extensions", "code")
  end

  test "3a.4 createAccountManager: duplicate email (case-insensitive) is rejected" do
    login_as!("admin@example.com", "Password123!")
    create_account_manager!(email: "manager@example.com", password: "Password123!", first_name: "Mary", last_name: "Manager")

    response = create_account_manager!(
      email: "MANAGER@EXAMPLE.COM",
      password: "Password123!",
      first_name: "Other",
      last_name: "Manager"
    )

    error = response.fetch("errors").first
    assert_equal "Users.EmailNotUnique", error.dig("extensions", "code")
    assert_equal 409, error.dig("extensions", "status")
  end

  test "3a.5 createAccountManager: non-admin caller is forbidden" do
    login_as!("member@example.com", "Password123!")

    response = create_account_manager!(
      email: "manager@example.com",
      password: "Password123!",
      first_name: "Mary",
      last_name: "Manager"
    )

    refute_nil response["errors"]
    assert_nil User.find_by(email: "manager@example.com")
  end

  # ---------------------------------------------------------------------------
  # End-to-end sign-up via invitation (3b.1)
  # ---------------------------------------------------------------------------

  test "3b.1 sign-up E2E: admin invites → invitee fetches details → invitee accepts and is logged in" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    raw_token = raw_invitation_token(invitee)

    reset_session_cookies!
    lookup = run_invitation_by_token_query(raw_token)
    assert_equal "nina@example.com", lookup.dig("data", "invitationByToken", "email")

    accept = run_accept_invitation(
      token: raw_token,
      password: "NewPass123!",
      password_confirmation: "NewPass123!",
      first_name: "Nina",
      last_name: "Final"
    )

    assert_equal true, accept.dig("data", "acceptInvitation", "authenticated")
    invitee.reload
    assert_equal true, invitee.email_confirmed
    assert_equal "Final", invitee.last_name
    assert_includes invitee.role_names, "member"
  end

  test "3b.3 re-invitation rotates token: original token becomes invalid" do
    login_as!("admin@example.com", "Password123!")
    send_invitation!(email: "nina@example.com", first_name: "Nina", last_name: "N", role_name: "member")
    invitee = User.find_by(email: "nina@example.com")
    original_token = raw_invitation_token(invitee)

    resend_invitation!(invitee.id)

    response = run_accept_invitation(
      token: original_token,
      password: "NewPass123!",
      password_confirmation: "NewPass123!",
      first_name: "Nina",
      last_name: "N"
    )

    error = response.fetch("errors").first
    assert_equal "Invitations.InvalidToken", error.dig("extensions", "code")
  end

  private

  # --- shared helpers --------------------------------------------------------

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

  def reset_session_cookies!
    cookies.each_key { |k| cookies.delete(k) }
  end

  # --- mutation/query helpers ------------------------------------------------

  LOGIN_MUTATION = <<~GRAPHQL.freeze
    mutation($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        authenticated
        userId
        roles
      }
    }
  GRAPHQL

  def login_as!(email, password)
    response = run_login_mutation(email, password)
    assert_equal true, response.dig("data", "login", "authenticated"), response.inspect
    response
  end

  def run_login_mutation(email, password)
    graphql(LOGIN_MUTATION, variables: { email: email, password: password })
  end

  SEND_INVITATION = <<~GRAPHQL.freeze
    mutation($email: String!, $firstName: String!, $lastName: String!, $roleName: String!) {
      sendInvitation(email: $email, firstName: $firstName, lastName: $lastName, roleName: $roleName) {
        id
        email
      }
    }
  GRAPHQL

  def send_invitation!(email:, first_name:, last_name:, role_name:)
    graphql(SEND_INVITATION, variables: {
      email: email,
      firstName: first_name,
      lastName: last_name,
      roleName: role_name
    })
  end

  RESEND_INVITATION = <<~GRAPHQL.freeze
    mutation($userId: ID!) {
      resendInvitation(userId: $userId) { success }
    }
  GRAPHQL

  def resend_invitation!(user_id)
    graphql(RESEND_INVITATION, variables: { userId: user_id })
  end

  ACCEPT_INVITATION = <<~GRAPHQL.freeze
    mutation($invitationToken: String!, $password: String!, $passwordConfirmation: String!, $firstName: String!, $lastName: String!) {
      acceptInvitation(invitationToken: $invitationToken, password: $password, passwordConfirmation: $passwordConfirmation, firstName: $firstName, lastName: $lastName) {
        authenticated
        userId
        roles
      }
    }
  GRAPHQL

  def run_accept_invitation(token:, password:, password_confirmation:, first_name:, last_name:)
    graphql(ACCEPT_INVITATION, variables: {
      invitationToken: token,
      password: password,
      passwordConfirmation: password_confirmation,
      firstName: first_name,
      lastName: last_name
    })
  end

  UPDATE_USER = <<~GRAPHQL.freeze
    mutation($id: ID!, $firstName: String, $lastName: String, $roleName: String) {
      updateUser(id: $id, firstName: $firstName, lastName: $lastName, roleName: $roleName) { success }
    }
  GRAPHQL

  def update_user!(id:, first_name: nil, last_name: nil, role_name: nil)
    graphql(UPDATE_USER, variables: {
      id: id,
      firstName: first_name,
      lastName: last_name,
      roleName: role_name
    })
  end

  DELETE_USER = <<~GRAPHQL.freeze
    mutation($id: ID!) { deleteUser(id: $id) { success } }
  GRAPHQL

  def delete_user!(id)
    graphql(DELETE_USER, variables: { id: id })
  end

  INVITATION_BY_TOKEN_QUERY = <<~GRAPHQL.freeze
    query($token: String!) { invitationByToken(token: $token) }
  GRAPHQL

  def run_invitation_by_token_query(token)
    graphql(INVITATION_BY_TOKEN_QUERY, variables: { token: token })
  end

  CREATE_ACCOUNT_MANAGER = <<~GRAPHQL.freeze
    mutation($email: String!, $password: String, $firstName: String, $lastName: String) {
      createAccountManager(email: $email, password: $password, firstName: $firstName, lastName: $lastName) { id }
    }
  GRAPHQL

  def create_account_manager!(email:, password: nil, first_name: nil, last_name: nil)
    graphql(CREATE_ACCOUNT_MANAGER, variables: {
      email: email,
      password: password,
      firstName: first_name,
      lastName: last_name
    })
  end

  # Devise-Invitable rotates `invitation_token` to a hashed value on persist.
  # The raw token (what the email link contains) is generated server-side at
  # invite time and is *not* stored. For tests we re-generate by calling the
  # private API: `User.invite!` returns the user with `raw_invitation_token`
  # set as a virtual attribute. When we don't have access to that (e.g. the
  # user was invited inside `send_invitation!`), we re-issue and use the
  # newly-issued raw token.
  def raw_invitation_token(user)
    raw_token, hashed_token = Devise.token_generator.generate(User, :invitation_token)
    user.update_columns(
      invitation_token: hashed_token,
      invitation_created_at: Time.current,
      invitation_sent_at: Time.current
    )
    raw_token
  end
end
