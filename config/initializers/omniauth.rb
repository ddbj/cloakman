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

  # OmniAuth rescues every StandardError, so nothing else would report these. Skip only what anyone can
  # cause without going through the sign-in flow, and going back to a used code.
  caused_by_request =
    case error
    when nil,
         ActionController::BadRequest,
         ActionController::InvalidAuthenticityToken,
         ActionDispatch::Http::Parameters::ParseError,
         OmniAuth::Strategies::OpenIDConnect::CallbackError,
         Rack::BadRequest
      true
    when Rack::OAuth2::Client::Error
      error.response[:error] == 'invalid_grant'
    else
      # The strategy calls `to_sym` on the `error` parameter, which can be missing, an array or invalid UTF-8.
      error.cause.is_a?(OmniAuth::Strategies::OpenIDConnect::CallbackError)
    end

  Sentry.capture_exception error unless caused_by_request

  # OmniAuth puts this in the redirect URL. Strategies can set it to an exception message or a request
  # parameter, and a long one makes the headers too large for the front Nginx, which answers 502.
  env['omniauth.error.type'] = :failed

  OmniAuth::FailureEndpoint.new(env).call
}
