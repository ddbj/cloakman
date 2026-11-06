keycloak     = Rails.application.config_for(:keycloak)
keycloak_url = URI.parse(keycloak.url!)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, **{
    name:         'keycloak',
    issuer:       URI.join(keycloak_url, '/realms/master').to_s,
    discovery:    true,
    origin_param: false,
    scope:        %i[openid email profile],
    prompt:       'login',

    client_options: {
      scheme:       keycloak_url.scheme,
      port:         keycloak_url.port,
      host:         keycloak_url.host,
      identifier:   keycloak.client_id,
      secret:       keycloak.client_secret,
      redirect_uri: URI.join(Rails.application.config_for(:app).app_url!, '/auth/keycloak/callback').to_s
    }
  }
end

OmniAuth.config.on_failure = ->(env) {
  error = env['omniauth.error']

  # Only report failures on our side. Anyone can make the others happen by requesting the callback URL.
  case error
  when OpenIDConnect::Exception, JSON::JWT::Exception, Faraday::Error, Timeout::Error, Errno::ETIMEDOUT, SocketError
    Sentry.capture_exception error
  when Rack::OAuth2::Client::Error
    Sentry.capture_exception error unless error.response[:error] == 'invalid_grant'
  end

  # OmniAuth puts this in the redirect URL. Strategies can set it to an exception message or a request
  # parameter, and a long one makes the headers too large for the front Nginx, which answers 502.
  env['omniauth.error.type'] = :failed

  OmniAuth::FailureEndpoint.new(env).call
}
