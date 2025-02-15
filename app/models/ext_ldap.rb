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
          username: ENV.fetch("EXT_LDAP_BIND_DN",  "cn=admin,dc=example,dc=org"),
          password: ENV.fetch("EXT_LDAP_PASSWORD", "adminpassword")
        },

        encryption: Rails.env.production? ? {
          method: :simple_tls,

          tls_options: {
            verify_mode: OpenSSL::SSL::VERIFY_NONE
          }
        } : nil
      )

      Thread.current.thread_variable_set(:ext_ldap_connection, conn)
    end
  end

  def base_dn
    ENV.fetch("EXT_LDAP_BASE_DN", "dc=example,dc=org")
  end
end
