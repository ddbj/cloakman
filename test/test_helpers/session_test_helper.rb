module SessionTestHelper
  def sign_in(user)
    OmniAuth.config.add_mock :keycloak, **{
      credentials: {
        id_token: 'ID_TOKEN'
      },

      extra: {
        raw_info: {
          preferred_username: user.id
        }
      }
    }

    begin
      if respond_to?(:visit)
        visit auth_callback_path('keycloak')
      else
        get auth_callback_path('keycloak')
      end
    ensure
      OmniAuth.config.mock_auth[:keycloak] = nil
    end
  end
end
