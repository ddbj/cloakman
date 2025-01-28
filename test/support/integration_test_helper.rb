module IntegrationTestHelper
  def sign_in(user)
    OmniAuth.config.add_mock :keycloak, extra: {
      raw_info: {
        preferred_username: user.username
      }
    }

    begin
      get auth_callback_path("keycloak")
    ensure
      OmniAuth.config.mock_auth[:keycloak] = nil
    end
  end
end
