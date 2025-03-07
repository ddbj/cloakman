module LDAP
  module_function

  def connection
    if conn = Thread.current.thread_variable_get(:ldap_connection)
      conn
    else
      config = Rails.application.config_for(:ldap)

      conn = Net::LDAP.new(
        host: config.host!,
        port: config.port!,

        auth: {
          method:   :simple,
          username: config.bind_dn!,
          password: config.password!
        }
      )

      Thread.current.thread_variable_set(:ldap_connection, conn)
    end
  end

  def base_dn
    "dc=ddbj,dc=nig,dc=ac,dc=jp"
  end
end
