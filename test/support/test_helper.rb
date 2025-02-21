using LDAPAssertion

module TestHelper
  def reset_data
    reset_ldap
    reset_ext_ldap
    reset_redis
  end

  def sign_in(user)
    OmniAuth.config.add_mock :keycloak, **{
      credentials: {
        id_token: "ID_TOKEN"
      },

      extra: {
        raw_info: {
          preferred_username: user.id
        }
      }
    }

    begin
      get auth_callback_path("keycloak")
    ensure
      OmniAuth.config.mock_auth[:keycloak] = nil
    end
  end

  private

  def reset_ldap
    User.all.each(&:destroy!)
    Reader.all.each(&:destroy!)
  end

  def reset_ext_ldap
    ExtLDAP.connection.assert_call(:search, **{
      base:   ExtLDAP.base_dn,
      filter: Net::LDAP::Filter.eq("objectClass", "account")
    }).each do |entry|
      ExtLDAP.connection.assert_call :delete, dn: entry.dn
    end
  end

  def reset_redis
    REDIS.call :select, 1
    REDIS.call :flushdb
    REDIS.call :set, "uid_number", 1000
  end
end
