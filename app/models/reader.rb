using GenerateSSHA
using LDAPAssertion

class Reader < LDAPEntry
  include HasSSHAPassword

  self.base_dn        = Rails.application.config_for(:ldap).readers_dn!
  self.ldap_id_attr   = :uid
  self.object_classes = %w[account simpleSecurityObject]

  self.ldap_to_model_map = {
    "uid"          => :id,
    "userPassword" => :password_digest
  }

  self.model_to_ldap_map = ldap_to_model_map.invert

  def self.endpoint = Rails.application.config_for(:app).ldap_internal_endpoint!

  before_save prepend: true do
    self.password ||= SecureRandom.base58 unless password_digest
  end
end
