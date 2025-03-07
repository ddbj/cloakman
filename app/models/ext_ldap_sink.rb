module ExtLDAPSink
  module_function

  def connection
    if conn = Thread.current.thread_variable_get(:ext_ldap_sink_connection)
      conn
    else
      config = Rails.application.config_for(:ext_ldap)

      conn = Net::LDAP.new(
        host: config.host!,
        port: config.port!,

        auth: {
          method:   :simple,
          username: config.sink.fetch(:bind_dn),
          password: config.sink.fetch(:password)
        },

        encryption: config.tls ? {
          method: :simple_tls,

          tls_options: {
            verify_mode: OpenSSL::SSL::VERIFY_NONE
          }
        } : nil
      )

      Thread.current.thread_variable_set(:ext_ldap_sink_connection, conn)
    end
  end

  def base_dn = Rails.application.config_for(:ext_ldap).sink.fetch(:base_dn)
end
