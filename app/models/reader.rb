using GenerateSSHA
using LDAPAssertion

class Reader < LDAPEntry
  self.base_dn        = "ou=readers,#{LDAP.base_dn}"
  self.ldap_id_attr   = :uid
  self.object_classes = %w[account simpleSecurityObject]

  self.model_to_ldap_map = {
    username:        :uid,
    password_digest: :userPassword
  }

  attribute :username,        :string
  attribute :password,        :string
  attribute :password_digest, :string

  validates :username, presence: true

  before_create do
    self.password        = Base58.binary_to_base58(SecureRandom.random_bytes)
    self.password_digest = password.generate_ssha
  end

  def self.endpoint = ENV.fetch("LDAP_INTERNAL_ENDPOINT", "ldap://localhost:1389")

  def to_param = username
end
