require "securerandom"

class RefreshTokenService
  def self.create_for_user!(user)
    expires_on = Time.now.utc + refresh_expiry_days.days
    RefreshToken.create!(
      user_id: user.id,
      token: SecureRandom.base64(32),
      expires_on_utc: expires_on
    )
  end

  def self.rotate!(token_record)
    token_record.update!(
      token: SecureRandom.base64(32),
      expires_on_utc: Time.now.utc + refresh_expiry_days.days
    )
    token_record
  end

  def self.find_valid(token_value)
    return nil if token_value.blank?

    token = RefreshToken.includes(:user).find_by(token: token_value)
    return nil if token.nil?
    return nil if token.expires_on_utc.nil?

    token.expires_on_utc + 5.seconds >= Time.now.utc ? token : nil
  end

  def self.refresh_expiry_days
    ENV.fetch("JWT_REFRESH_TOKEN_EXPIRY_DAYS", "14").to_i
  end
end
