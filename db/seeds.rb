require "securerandom"
require_relative "seeds/master_geography"

# ── Geography & Currencies ──────────────────────────────────────────

geo_result = Seeds::MasterGeography.seed!
puts "Master geography seed complete: #{geo_result.inspect}"

CURRENCY_SEEDS = [
  { code: "AED", symbol: "AED", name: "United Arab Emirates Dirham" },
  { code: "AUD", symbol: "A$",  name: "Australian Dollar" },
  { code: "BRL", symbol: "R$",  name: "Brazilian Real" },
  { code: "CAD", symbol: "C$",  name: "Canadian Dollar" },
  { code: "CHF", symbol: "CHF", name: "Swiss Franc" },
  { code: "CNY", symbol: "¥",   name: "Chinese Yuan" },
  { code: "DKK", symbol: "DKK", name: "Danish Krone" },
  { code: "EUR", symbol: "€",   name: "Euro" },
  { code: "GBP", symbol: "£",   name: "British Pound" },
  { code: "HKD", symbol: "HK$", name: "Hong Kong Dollar" },
  { code: "INR", symbol: "₹",   name: "Indian Rupee" },
  { code: "JPY", symbol: "¥",   name: "Japanese Yen" },
  { code: "KRW", symbol: "₩",   name: "South Korean Won" },
  { code: "MXN", symbol: "M$",  name: "Mexican Peso" },
  { code: "NOK", symbol: "NOK", name: "Norwegian Krone" },
  { code: "NZD", symbol: "NZ$", name: "New Zealand Dollar" },
  { code: "PHP", symbol: "₱",   name: "Philippine Peso" },
  { code: "PLN", symbol: "zł",  name: "Polish Zloty" },
  { code: "SAR", symbol: "SAR", name: "Saudi Riyal" },
  { code: "SEK", symbol: "SEK", name: "Swedish Krona" },
  { code: "SGD", symbol: "S$",  name: "Singapore Dollar" },
  { code: "TWD", symbol: "NT$", name: "New Taiwan Dollar" },
  { code: "USD", symbol: "$",   name: "United States Dollar" }
].freeze

ActiveRecord::Base.transaction do
  CURRENCY_SEEDS.each do |attrs|
    currency = Currency.find_or_initialize_by(code: attrs[:code])
    currency.symbol = attrs[:symbol]
    currency.name   = attrs[:name]
    currency.decimal_places ||= 2        if currency.respond_to?(:decimal_places=)
    currency.is_active       = true      if currency.respond_to?(:is_active=)
    currency.created_at_utc ||= Time.current.utc if currency.respond_to?(:created_at_utc=)
    currency.updated_at_utc  = Time.current.utc  if currency.respond_to?(:updated_at_utc=)
    currency.save!
  end
end
puts "Currency seed complete: #{Currency.count} currencies ensured."

# ── Roles ────────────────────────────────────────────────────────────

ROLE_NAMES = %w[superadmin admin account_manager data_manager member].freeze

ROLE_NAMES.each do |name|
  Role.find_or_create_by!(name: name) do |role|
    role.normalized_name   = name.upcase
    role.concurrency_stamp = SecureRandom.uuid
  end
end
puts "Roles seed complete: #{Role.pluck(:name).join(', ')}"

# ── Seed Users ───────────────────────────────────────────────────────

SEED_USERS = [
  { email: "admin@aqvc.com",    password: "Admin123!",    first_name: "Admin",    last_name: "Test", role: :admin },
  { email: "accmgr1@aqvc.com",  password: "Password123!", first_name: "AccMgr 1", last_name: "Test", role: :account_manager },
  { email: "accmgr2@aqvc.com",  password: "Password123!", first_name: "AccMgr 2", last_name: "Test", role: :account_manager },
  { email: "datamgr1@aqvc.com", password: "Password123!", first_name: "DataMgr",  last_name: "Test", role: :data_manager }
].freeze

ActiveRecord::Base.transaction do
  admin_user = nil

  SEED_USERS.each do |attrs|
    user = User.find_or_initialize_by(email: attrs[:email])
    user.user_name              = attrs[:email]
    user.first_name             = attrs[:first_name]
    user.last_name              = attrs[:last_name]
    user.email_confirmed        = true
    user.password               = attrs[:password]
    user.password_confirmation  = attrs[:password]
    user.security_stamp       ||= SecureRandom.uuid
    user.concurrency_stamp    ||= SecureRandom.uuid
    user.access_failed_count  ||= 0
    user.lockout_enabled        = true  if user.lockout_enabled.nil?
    user.phone_number_confirmed = false if user.phone_number_confirmed.nil?
    user.two_factor_enabled     = false if user.two_factor_enabled.nil?

    # First user (admin) is self-referencing; others reference admin
    if admin_user.nil?
      user.id ||= SecureRandom.uuid
      user.created_by_id = user.id
      user.save!(validate: false)
      admin_user = user
    else
      user.created_by_id ||= admin_user.id
      user.save!
    end

    user.add_role(attrs[:role]) unless user.has_role?(attrs[:role])
  end
end

puts "Seed complete: #{User.count} users, #{Role.count} roles."
