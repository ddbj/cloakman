config       = Rails.application.config_for(:keycloak)
keycloak_url = URI.parse(config.url!)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, **{
    name:          "keycloak",
    issuer:        "#{keycloak_url}/realms/master",
    discovery:     true,
    scope:         %i[openid email profile],
    prompt:        "login",

    client_options: {
      scheme:       keycloak_url.scheme,
      port:         keycloak_url.port,
      host:         keycloak_url.host,
      identifier:   config.client_id,
      secret:       config.client_secret,
      redirect_uri: "#{Rails.application.config_for(:app).app_url!}/auth/keycloak/callback"
    }
  }
end
