require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "logout" do
    sign_in FactoryBot.create(:user)

    delete session_path

    assert_redirected_to "http://keycloak.example.com/realms/master/protocol/openid-connect/logout?id_token_hint=ID_TOKEN&post_logout_redirect_uri=http%3A%2F%2Fwww.example.com%2F"
  end
end
