using GenerateSSHA
using LDAPAssertion

class Reader < LDAPEntry
  include HasSSHAPassword

  self.base_dn        = "ou=readers,#{LDAP.base_dn}"
  self.ldap_id_attr   = :uid
  self.object_classes = %w[account simpleSecurityObject]

  self.model_to_ldap_map = {
    username:        :uid,
    password_digest: :userPassword
  }

  attribute :username, :string

  validates :username, presence: true

  before_save prepend: true do
    self.password = Base58.binary_to_base58(SecureRandom.random_bytes) unless password_digest
  end

  def self.endpoint = ENV.fetch("LDAP_INTERNAL_ENDPOINT", "ldap://localhost:1389")

  def to_param = username
end
