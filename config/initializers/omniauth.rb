keycloak_url = Rails.application.config.x.keycloak_url

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, **{
    name:          "keycloak",
    issuer:        "#{keycloak_url}/realms/#{ENV.fetch("KEYCLOAK_REALM", "master")}",
    discovery:     true,
    scope:         %i[openid email profile],
    prompt:        "login",

    client_options: {
      scheme:       keycloak_url.scheme,
      port:         keycloak_url.port,
      host:         keycloak_url.host,
      identifier:   ENV.fetch("KEYCLOAK_CLIENT_ID", "cloakman"),
      secret:       ENV["KEYCLOAK_CLIENT_SECRET"],
      redirect_uri: "#{ENV["APP_URL"]}/auth/keycloak/callback"
    }
  }
end
