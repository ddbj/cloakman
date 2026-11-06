class APIKey < ApplicationRecord
  attr_reader :token

  validates :name, presence: true, uniqueness: true

  before_create :generate_token

  def self.authenticate(token)
    find_by(token_digest: digest(token))
  end

  # Tokens are long random values, so a fast hash is enough. There is nothing to brute-force.
  def self.digest(token)
    OpenSSL::Digest::SHA256.hexdigest(token)
  end

  private

  def generate_token
    @token            = self.class.generate_unique_secure_token
    self.token_digest = self.class.digest(@token)
  end
end
