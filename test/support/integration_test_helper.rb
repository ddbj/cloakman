module IntegrationTestHelper
  def stub_token_request
    stub_request(:post, "http://keycloak.example.com/realms/master/protocol/openid-connect/token").to_return_json(
      body: {
        access_token:  "ACCESS_TOKEN",
        token_type:    "Bearer",
        expires_in:    3600,
        refresh_token: "REFRESH_TOKEN",
        scope:         "openid"
      }
    )
  end

  def sign_in(account)
    OmniAuth.config.add_mock :keycloak, uid: account.id

    begin
      get auth_callback_path("keycloak")
    ensure
      OmniAuth.config.mock_auth[:keycloak] = nil
    end

    stub_request(:get, "http://keycloak.example.com/admin/realms/master/users/#{account.id}").to_return_json(
      body: account.to_payload(
        include_id:       true,
        include_username: true
      )
    )
  end
end
