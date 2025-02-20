module LDAP
  module_function

  def connection
    if conn = Thread.current.thread_variable_get(:ldap_connection)
      conn
    else
      conn = Net::LDAP.new(
        host: ENV.fetch("LDAP_HOST", "localhost"),
        port: ENV.fetch("LDAP_PORT", 1389),

        auth: {
          method:   :simple,
          username: ENV.fetch("LDAP_ADMIN_BIND_DN",  "cn=admin,dc=ddbj,dc=nig,dc=ac,dc=jp"),
          password: ENV.fetch("LDAP_ADMIN_PASSWORD", "adminpassword")
        }
      )

      Thread.current.thread_variable_set(:ldap_connection, conn)
    end
  end

  def base_dn
    ENV.fetch("LDAP_BASE_DN", "dc=ddbj,dc=nig,dc=ac,dc=jp")
  end
end
