require "securerandom"

ADMIN_USER_ID = "11111111-1111-1111-1111-111111111111".freeze
ACCOUNT_MANAGER_1_USER_ID = "22222222-2222-2222-2222-222222222222".freeze
ACCOUNT_MANAGER_2_USER_ID = "33333333-3333-3333-3333-333333333333".freeze
DATA_MANAGER_1_USER_ID = "44444444-4444-4444-4444-444444444444".freeze

ADMIN_ROLE_ID = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa".freeze
ACCOUNT_MANAGER_ROLE_ID = "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb".freeze
DATA_MANAGER_ROLE_ID = "cccccccc-cccc-cccc-cccc-cccccccccccc".freeze

# Mirrors legacy .NET seed hashes so existing credentials continue to work:
# Devise-backed development credentials:
# - admin@aqvc.com => Admin123!
# - other seed users => Password123!
ADMIN_PASSWORD = "Admin123!".freeze
DEFAULT_PASSWORD = "Password123!".freeze

SEED_TIMESTAMP = Time.utc(2025, 6, 25)

def upsert_role(id:, name:, normalized_name:)
  role = Role.find_or_initialize_by(id: id)
  role.name = name
  role.normalized_name = normalized_name
  role.concurrency_stamp ||= SecureRandom.uuid
  role.save!
  role
end

def upsert_user(id:, email:, password:, created_by_id:)
  user = User.find_or_initialize_by(id: id)
  user.email = email
  user.user_name = email
  user.normalized_email = email.upcase
  user.normalized_user_name = email.upcase
  user.email_confirmed = true
  user.password = password
  user.password_confirmation = password
  user.security_stamp ||= id
  user.concurrency_stamp ||= id
  user.access_failed_count ||= 0
  user.lockout_enabled = true if user.lockout_enabled.nil?
  user.phone_number_confirmed = false if user.phone_number_confirmed.nil?
  user.two_factor_enabled = false if user.two_factor_enabled.nil?
  user.created_at_utc ||= SEED_TIMESTAMP
  user.created_by_id ||= created_by_id
  user.save!
  user
end

def upsert_user_detail(id:, first_name:, last_name:, created_by_id:)
  detail = UserDetail.find_or_initialize_by(id: id)
  detail.first_name = first_name
  detail.last_name = last_name
  detail.created_at_utc ||= SEED_TIMESTAMP
  detail.created_by_id ||= created_by_id
  detail.save!
  detail
end

def ensure_user_role(user_id:, role_id:)
  return if UserRole.exists?(user_id: user_id, role_id: role_id)

  UserRole.create!(user_id: user_id, role_id: role_id)
end

ActiveRecord::Base.transaction do
  admin_role = upsert_role(id: ADMIN_ROLE_ID, name: "Admin", normalized_name: "ADMIN")
  account_manager_role = upsert_role(
    id: ACCOUNT_MANAGER_ROLE_ID,
    name: "AccountManager",
    normalized_name: "ACCOUNTMANAGER"
  )
  data_manager_role = upsert_role(
    id: DATA_MANAGER_ROLE_ID,
    name: "DataManager",
    normalized_name: "DATAMANAGER"
  )

  admin = upsert_user(
    id: ADMIN_USER_ID,
    email: "admin@aqvc.com",
    password: ADMIN_PASSWORD,
    created_by_id: ADMIN_USER_ID
  )

  accmgr1 = upsert_user(
    id: ACCOUNT_MANAGER_1_USER_ID,
    email: "accmgr1@aqvc.com",
    password: DEFAULT_PASSWORD,
    created_by_id: ADMIN_USER_ID
  )

  accmgr2 = upsert_user(
    id: ACCOUNT_MANAGER_2_USER_ID,
    email: "accmgr2@aqvc.com",
    password: DEFAULT_PASSWORD,
    created_by_id: ADMIN_USER_ID
  )

  datamgr1 = upsert_user(
    id: DATA_MANAGER_1_USER_ID,
    email: "datamgr1@aqvc.com",
    password: DEFAULT_PASSWORD,
    created_by_id: ADMIN_USER_ID
  )

  upsert_user_detail(
    id: admin.id,
    first_name: "Admin",
    last_name: "Test",
    created_by_id: ADMIN_USER_ID
  )
  upsert_user_detail(
    id: accmgr1.id,
    first_name: "AccMgr 1",
    last_name: "Test",
    created_by_id: ADMIN_USER_ID
  )
  upsert_user_detail(
    id: accmgr2.id,
    first_name: "AccMgr 2",
    last_name: "Test",
    created_by_id: ADMIN_USER_ID
  )
  upsert_user_detail(
    id: datamgr1.id,
    first_name: "DataMgr",
    last_name: "Test",
    created_by_id: ADMIN_USER_ID
  )

  ensure_user_role(user_id: admin.id, role_id: admin_role.id)
  ensure_user_role(user_id: accmgr1.id, role_id: account_manager_role.id)
  ensure_user_role(user_id: accmgr2.id, role_id: account_manager_role.id)
  ensure_user_role(user_id: datamgr1.id, role_id: data_manager_role.id)
end

puts "Seed complete: roles/users/user_details/user_roles ensured."
