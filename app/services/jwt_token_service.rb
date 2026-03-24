require "jwt"

class JwtTokenService
  ROLE_CLAIM = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role".freeze
  NAME_CLAIM = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name".freeze
  NAME_ID_CLAIM = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier".freeze

  def self.issue_access_token(user:, roles:)
    now = Time.now.to_i
    expiry_minutes = ENV.fetch("JWT_EXPIRY_MINUTES", "5").to_i

    payload = {
      NAME_CLAIM => user.user_name.to_s,
      NAME_ID_CLAIM => user.id.to_s,
      ROLE_CLAIM => roles,
      iss: ENV.fetch("JWT_ISSUER", "AQVC_Hub"),
      aud: ENV.fetch("JWT_AUDIENCE", "AQVC_Hub"),
      iat: now,
      exp: now + (expiry_minutes * 60)
    }

    JWT.encode(payload, ENV.fetch("JWT_SECRET", "666abd2d-72bc-4acd-a5b2-1cf5783c259a"), "HS256")
  end

  def self.decode_access_token(token)
    JWT.decode(
      token,
      ENV.fetch("JWT_SECRET", "666abd2d-72bc-4acd-a5b2-1cf5783c259a"),
      true,
      {
        algorithm: "HS256",
        verify_iss: true,
        iss: ENV.fetch("JWT_ISSUER", "AQVC_Hub"),
        verify_aud: true,
        aud: ENV.fetch("JWT_AUDIENCE", "AQVC_Hub")
      }
    ).first
  end
end
