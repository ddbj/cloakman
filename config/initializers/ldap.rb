if Rails.env.local?
  require_relative '../../app/refinements/ldap_assertion'

  using LDAPAssertion

  Rails.application.config.to_prepare do
    [
      Rails.application.config_for(:ldap).users_dn!,
      Rails.application.config_for(:ldap).readers_dn!
    ].each do |dn|
      LDAP.connection.assert_call :add, **{
        dn:,

        attributes: {
          objectClass: %w[organizationalUnit],
          ou:          dn.split(',').first.delete_prefix('ou=')
        }
      }
    rescue LDAPError::EntryAlreadyExists
      # do nothing
    rescue Errno::ECONNREFUSED
      sleep 1
      retry
    end
  end
end
