using LDAPAssertion

module TestHelper
  def reset_data
    reset_ldap
    reset_ext_ldap
    reset_redis
  end

  def sign_in(user)
    OmniAuth.config.add_mock :keycloak, extra: {
      raw_info: {
        preferred_username: user.username
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
    begin
      LDAP.connection.assert_call :search, **{
        base:          LDAP.base_dn,
        scope:         Net::LDAP::SearchScope_BaseObject,
        return_result: false
      }
    rescue LDAPError::NoSuchObject
      # do nothing
    else
      LDAP.connection.assert_call :delete_tree, dn: LDAP.base_dn
    end

    LDAP.connection.assert_call :add, **{
      dn: LDAP.base_dn,

      attributes: {
        objectClass: %w[dcObject organization],
        dc:          "example",
        o:           "example"
      }
    }

    LDAP.connection.assert_call :add, **{
      dn: User.users_dn,

      attributes: {
        objectClass: %w[organizationalUnit],
        ou:          "users"
      }
    }

    LDAP.connection.assert_call :add, **{
      dn: Service.services_dn,

      attributes: {
        objectClass: %w[organizationalUnit],
        ou:          "services"
      }
    }
  end

  def reset_ext_ldap
    begin
      ExtLDAP.connection.assert_call :search, **{
        base:          ExtLDAP.base_dn,
        scope:         Net::LDAP::SearchScope_BaseObject,
        return_result: false
      }
    rescue LDAPError::NoSuchObject
      # do nothing
    else
      ExtLDAP.connection.assert_call :delete_tree, dn: ExtLDAP.base_dn
    end

    ExtLDAP.connection.assert_call :add, **{
      dn: ExtLDAP.base_dn,

      attributes: {
        objectClass: %w[dcObject organization],
        dc:          "example",
        o:           "example"
      }
    }

    ExtLDAP.connection.assert_call :add, **{
      dn: "ou=people,#{ExtLDAP.base_dn}",

      attributes: {
        objectClass: %w[organizationalUnit],
        ou:          "people"
      }
    }
  end

  def reset_redis
    REDIS.call :select, 1
    REDIS.call :flushdb
    REDIS.call :set, "uid_number", 1000
  end
end
