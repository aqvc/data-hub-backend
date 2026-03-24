require "base64"
require "openssl"

class User < ApplicationRecord
  devise :database_authenticatable, :validatable

  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id, optional: true
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :refresh_tokens
  has_many :created_users, class_name: "User", foreign_key: :created_by_id, dependent: nil
  has_many :updated_users, class_name: "User", foreign_key: :updated_by_id, dependent: nil
  has_many :created_activities, class_name: "Activity", foreign_key: :created_by_id, dependent: nil
  has_many :updated_activities, class_name: "Activity", foreign_key: :updated_by_id, dependent: nil
  has_many :created_engagements, class_name: "Engagement", foreign_key: :created_by_id, dependent: nil
  has_many :updated_engagements, class_name: "Engagement", foreign_key: :updated_by_id, dependent: nil
  has_many :created_fund_profiles, class_name: "FundProfile", foreign_key: :created_by_id, dependent: nil
  has_many :updated_fund_profiles, class_name: "FundProfile", foreign_key: :updated_by_id, dependent: nil
  has_many :owned_organization_contacts, class_name: "OrganizationContact", foreign_key: :owner_id, dependent: nil
  has_many :created_organization_contacts, class_name: "OrganizationContact", foreign_key: :created_by_id, dependent: nil
  has_many :updated_organization_contacts, class_name: "OrganizationContact", foreign_key: :updated_by_id, dependent: nil
  has_many :organization_members
  has_many :owned_prospect_jobs, class_name: "ProspectJob", foreign_key: :owner_id, dependent: nil
  has_many :created_prospect_jobs, class_name: "ProspectJob", foreign_key: :created_by_id, dependent: nil
  has_many :updated_prospect_jobs, class_name: "ProspectJob", foreign_key: :updated_by_id, dependent: nil

  before_validation :normalize_auth_fields

  # Devise expects this attribute. Some local databases may not have the
  # `encrypted_password` column yet, so expose a safe accessor.
  def encrypted_password
    has_attribute?(:encrypted_password) ? self[:encrypted_password] : nil
  end

  def encrypted_password=(value)
    self[:encrypted_password] = value if has_attribute?(:encrypted_password)
  end

  # Supports both Devise hashes and legacy ASP.NET Identity hashes.
  def valid_password?(password)
    return true if super(password)

    valid_legacy_password_and_migrate(password)
  rescue BCrypt::Errors::InvalidHash
    valid_legacy_password_and_migrate(password)
  end

  private

  def valid_legacy_password_and_migrate(password)
    return false if password_hash.blank?

    valid = legacy_password_valid?(password)
    return false unless valid

    # Opportunistically migrate to Devise hash format.
    if has_attribute?(:encrypted_password) && self[:encrypted_password].blank?
      self.password = password
      self.password_confirmation = password
      save(validate: false)
    end

    true
  end

  def legacy_password_valid?(password)
    raw = Base64.strict_decode64(password_hash)
    return false if raw.bytesize < 1

    version = raw.getbyte(0)
    case version
    when 0
      legacy_v2_password_valid?(raw, password)
    when 1
      legacy_v3_password_valid?(raw, password)
    else
      false
    end
  rescue ArgumentError
    false
  end

  # ASP.NET Identity V2:
  # 0x00 | 16-byte salt | 32-byte subkey (PBKDF2-HMAC-SHA1, 1000 iterations)
  def legacy_v2_password_valid?(raw, password)
    return false unless raw.bytesize == 49

    salt = raw.byteslice(1, 16)
    expected_subkey = raw.byteslice(17, 32)
    actual_subkey = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 1000, 32, "sha1")

    ActiveSupport::SecurityUtils.secure_compare(actual_subkey, expected_subkey)
  end

  # ASP.NET Identity V3:
  # 0x01 | prf(4) | iter(4) | salt_len(4) | salt | subkey
  def legacy_v3_password_valid?(raw, password)
    return false if raw.bytesize < 13

    prf = raw.byteslice(1, 4).unpack1("N")
    iterations = raw.byteslice(5, 4).unpack1("N")
    salt_length = raw.byteslice(9, 4).unpack1("N")

    return false if salt_length <= 0
    return false if raw.bytesize < (13 + salt_length + 1)

    salt = raw.byteslice(13, salt_length)
    expected_subkey = raw.byteslice(13 + salt_length, raw.bytesize - 13 - salt_length)
    return false if expected_subkey.blank?

    digest = case prf
             when 0 then "sha1"
             when 1 then "sha256"
             when 2 then "sha512"
             else
               return false
             end

    actual_subkey = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iterations, expected_subkey.bytesize, digest)
    ActiveSupport::SecurityUtils.secure_compare(actual_subkey, expected_subkey)
  end

  def normalize_auth_fields
    normalized_email_value = email.to_s.strip.downcase
    return if normalized_email_value.blank?

    self.email = normalized_email_value
    self.user_name = normalized_email_value if user_name.blank?
    self.normalized_email = normalized_email_value.upcase
    self.normalized_user_name = user_name.to_s.upcase if user_name.present?
  end

end
