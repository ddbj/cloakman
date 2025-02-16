using GenerateSSHA
using LDAPAssertion

class Reader < LDAPEntry
  include HasSSHAPassword

  self.base_dn        = "ou=readers,#{LDAP.base_dn}"
  self.ldap_id_attr   = :uid
  self.object_classes = %w[account simpleSecurityObject]

  self.model_to_ldap_map = {
    id:              :uid,
    password_digest: :userPassword
  }

  def self.endpoint = ENV.fetch("LDAP_INTERNAL_ENDPOINT", "ldap://localhost:1389")

  before_save prepend: true do
    self.password = Base58.binary_to_base58(SecureRandom.random_bytes) unless password_digest
  end
end
