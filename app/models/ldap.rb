module LDAP
  def self.connection
    if conn = Thread.current.thread_variable_get(:ldap_connection)
      conn
    else
      conn = Net::LDAP.new(
        host: "localhost",
        port: 1389,

        auth: {
          method:   :simple,
          username: "cn=admin,dc=ddbj,dc=nig,dc=ac,dc=jp",
          password: "adminpassword"
        }
      )

      Thread.current.thread_variable_set(:ldap_connection, conn)
    end
  end
end
