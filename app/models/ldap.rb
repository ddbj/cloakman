module LDAP
  module_function

  def connection
    if conn = Thread.current.thread_variable_get(:ldap_connection)
      conn
    else
      conn = Net::LDAP.new(
        host: ENV.fetch("LDAP_HOST", "localhost"),
        port: ENV.fetch("LDAP_PORT", 1636),

        auth: {
          method:   :simple,
          username: ENV.fetch("LDAP_ADMIN_DN",       "cn=admin,dc=example,dc=org"),
          password: ENV.fetch("LDAP_ADMIN_PASSWORD", "adminpassword")
        },

        encryption: :simple_tls
      )

      Thread.current.thread_variable_set(:ldap_connection, conn)
    end
  end

  def users_dn
    ENV.fetch("LDAP_USERS_DN", "ou=users,dc=example,dc=org")
  end
end
