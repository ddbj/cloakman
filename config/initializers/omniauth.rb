keycloak_url = URI.parse(ENV["KEYCLOAK_URL"])

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, **{
    name:          "keycloak",
    issuer:        "#{keycloak_url}/realms/#{ENV["KEYCLOAK_REALM"]}",
    discovery:     true,
    scope:         %i[openid email profile],
    prompt:        "login",

    client_options: {
      scheme:       keycloak_url.scheme,
      port:         keycloak_url.port,
      host:         keycloak_url.host,
      identifier:   ENV["KEYCLOAK_CLIENT_ID"],
      secret:       ENV["KEYCLOAK_CLIENT_SECRET"],
      redirect_uri: "#{ENV["APP_URL"]}/auth/keycloak/callback"
    }
  }
end
