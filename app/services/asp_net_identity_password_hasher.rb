require "openssl"
require "base64"
require "securerandom"

class AspNetIdentityPasswordHasher
  # ASP.NET Core Identity v3:
  # [0x01][prf:4][iter_count:4][salt_len:4][salt][subkey]
  PRF_HMACSHA512 = 2
  DEFAULT_ITERATIONS = 100_000
  DEFAULT_SALT_SIZE = 16
  DEFAULT_SUBKEY_SIZE = 32

  def self.hash_password(plain_password)
    raise ArgumentError, "Password cannot be blank" if plain_password.blank?

    salt = SecureRandom.random_bytes(DEFAULT_SALT_SIZE)
    subkey = OpenSSL::KDF.pbkdf2_hmac(
      plain_password,
      salt: salt,
      iterations: DEFAULT_ITERATIONS,
      length: DEFAULT_SUBKEY_SIZE,
      hash: "sha512"
    )

    output = String.new.b
    output << [0x01].pack("C")
    output << [PRF_HMACSHA512].pack("N")
    output << [DEFAULT_ITERATIONS].pack("N")
    output << [DEFAULT_SALT_SIZE].pack("N")
    output << salt
    output << subkey

    Base64.strict_encode64(output)
  end
end
