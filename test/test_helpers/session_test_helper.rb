module SessionTestHelper
  def sign_in(user)
    OmniAuth.config.add_mock :keycloak, **{
      credentials: {
        id_token: "ID_TOKEN"
      },

      extra: {
        raw_info: {
          preferred_username: user.id
        }
      }
    }

    begin
      get auth_callback_path("keycloak")
    ensure
      OmniAuth.config.mock_auth[:keycloak] = nil
    end
  end
end
