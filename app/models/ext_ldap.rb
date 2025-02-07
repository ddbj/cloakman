module ExtLDAP
  module_function

  def connection
    if conn = Thread.current.thread_variable_get(:ext_ldap_connection)
      conn
    else
      conn = Net::LDAP.new(
        host: ENV.fetch("EXT_LDAP_HOST", "localhost"),
        port: ENV.fetch("EXT_LDAP_PORT", 3389),

        auth: {
          method:   :simple,
          username: ENV.fetch("EXT_LDAP_ADMIN_DN",       "cn=admin,dc=example,dc=org"),
          password: ENV.fetch("EXT_LDAP_ADMIN_PASSWORD", "adminpassword")
        },

        encryption: Rails.env.production? ? :simple_tls : nil
      )

      Thread.current.thread_variable_set(:ext_ldap_connection, conn)
    end
  end

  def users_dn
    ENV.fetch("EXT_LDAP_USERS_DN", "ou=users,dc=example,dc=org")
  end
end
