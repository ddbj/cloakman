require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest
  FAILURE_PATH = '/auth/failure?message=failed&strategy=keycloak'

  test 'logout' do
    sign_in FactoryBot.create(:user)

    delete session_path

    assert_redirected_to 'http://keycloak.example.com/realms/master/protocol/openid-connect/logout?id_token_hint=ID_TOKEN&post_logout_redirect_uri=http%3A%2F%2Fwww.example.com%2F'
  end

  test 'reports a discovery failure and keeps the redirect short' do
    error  = OpenIDConnect::Discovery::DiscoveryFailed.new('x' * 10_000)
    raiser = ->(*) { raise error }

    reported = capture_reports {
      OpenIDConnect::Discovery::Provider::Config.stub :discover!, raiser do
        without_omniauth_test_mode { post '/auth/keycloak', params: {origin: '/' * 2_500} }
      end
    }

    assert_equal [error], reported
    assert_redirected_to FAILURE_PATH
  end

  test 'keeps the redirect short and reports nothing for error parameters in the callback' do
    [
      {error: '~' * 7_000, error_description: 'description'},
      {error: 'access_denied'},
      {error_reason: 'reason'},
      {error: ['array']},
      {error: {key: 'value'}},
      {state: 'invalid', code: 'code'}
    ].each do |params|
      reported = capture_reports {
        without_omniauth_test_mode { get '/auth/keycloak/callback', params: }
      }

      assert_empty reported, params.to_s
      assert_redirected_to FAILURE_PATH
    end
  end

  test 'reports nothing for a callback URL that cannot be parsed' do
    [
      'state=%E0%A4%A',
      'state=1&state[a]=2',
      'error=%FF'
    ].each do |query|
      reported = capture_reports {
        without_omniauth_test_mode { get "/auth/keycloak/callback?#{query}" }
      }

      assert_empty reported, query
      assert_redirected_to FAILURE_PATH
    end
  end

  test 'reports failures on our side, including unexpected ones' do
    [
      OpenIDConnect::HttpError.new(500, 'Internal Server Error'),
      OpenIDConnect::ResponseObject::IdToken::InvalidAudience.new('Invalid audience'),
      JSON::JWK::Set::KidNotFound.new,
      JSON::JWS::VerificationFailed.new,
      Faraday::ParsingError.new('unexpected token'),
      Timeout::Error.new,
      Errno::ETIMEDOUT.new,
      SocketError.new,
      Rack::OAuth2::Client::Error.new(401, {error: 'invalid_client'}),
      ArgumentError.new('wrong number of arguments'),
      NoMethodError.new('undefined method')
    ].each do |error|
      assert_equal [error], capture_reports { fail_with error }
    end
  end

  test 'reports nothing for a sign-in request that fails CSRF protection or cannot be parsed' do
    [
      {},
      {params: 'a=%', headers: {'CONTENT_TYPE' => 'application/x-www-form-urlencoded'}},
      {params: '{', headers: {'CONTENT_TYPE' => 'application/json'}}
    ].each do |request|
      reported = capture_reports {
        without_omniauth_test_mode do
          with_forgery_protection { post '/auth/keycloak', **request }
        end
      }

      assert_empty reported, request.to_s
      assert_redirected_to FAILURE_PATH
    end
  end

  test 'does not report a stale authorization code' do
    error = Rack::OAuth2::Client::Error.new(400, {error: 'invalid_grant'})

    assert_empty capture_reports { fail_with error }
  end

  test 'shows a fixed message on the failure page whatever the parameters say' do
    get '/auth/failure', params: {message: 'Your account was hacked'}

    assert_redirected_to root_path
    assert_equal 'Sign in failed. Please try again.', flash[:alert]
  end

  private

  def fail_with(error)
    env = Rack::MockRequest.env_for('/auth/keycloak/callback').merge(
      'omniauth.error'      => error,
      'omniauth.error.type' => :failed
    )

    OmniAuth.config.on_failure.call env
  end

  def capture_reports
    reported = []

    Sentry.stub(:capture_exception, ->(error) { reported << error }) { yield }

    reported
  end

  def with_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    yield
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  def without_omniauth_test_mode
    OmniAuth.config.test_mode = false

    yield
  ensure
    OmniAuth.config.test_mode = true
  end
end
