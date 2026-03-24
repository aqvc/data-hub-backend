require "openssl"
require "base64"

class AspNetIdentityPasswordVerifier
  # ASP.NET Core Identity v3 password hash format:
  # [0x01][prf:4][iter_count:4][salt_len:4][salt][subkey]
  def self.valid_password?(hashed_password, plain_password)
    return false if hashed_password.blank? || plain_password.blank?

    decoded = Base64.strict_decode64(hashed_password)
    return false if decoded.nil? || decoded.bytesize < 13
    return false unless decoded.getbyte(0) == 0x01

    prf = decoded.byteslice(1, 4).unpack1("N")
    iterations = decoded.byteslice(5, 4).unpack1("N")
    salt_length = decoded.byteslice(9, 4).unpack1("N")

    return false if salt_length <= 0
    return false if decoded.bytesize < 13 + salt_length

    salt = decoded.byteslice(13, salt_length)
    expected_subkey = decoded.byteslice(13 + salt_length, decoded.bytesize - 13 - salt_length)
    return false if expected_subkey.blank?

    digest = case prf
             when 0 then "sha1"
             when 1 then "sha256"
             when 2 then "sha512"
             else
               return false
             end

    actual_subkey = OpenSSL::KDF.pbkdf2_hmac(
      plain_password,
      salt: salt,
      iterations: iterations,
      length: expected_subkey.bytesize,
      hash: digest
    )

    ActiveSupport::SecurityUtils.secure_compare(actual_subkey, expected_subkey)
  rescue StandardError
    false
  end
end
