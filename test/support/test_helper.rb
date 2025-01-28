module TestHelper
  def reset_data
    LDAP.connection.search base: ENV.fetch("LDAP_BASE_DN"), scope: Net::LDAP::SearchScope_SingleLevel do |entry|
      LDAP.connection.delete dn: entry.dn
    end

    REDIS.call :select, 1
    REDIS.call :flushdb
    REDIS.call :set, "uid_number", 1000
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
end
