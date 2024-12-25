require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "account created successfully" do
    stub_request(:post, "http://keycloak.example.com/realms/master/protocol/openid-connect/token").to_return_json(
      body: {
        access_token:  "ACCESS_TOKEN",
        token_type:    "Bearer",
        expires_in:    3600,
        refresh_token: "REFRESH_TOKEN",
        scope:         "openid"
      }
    )

    stub_request(:post, "http://keycloak.example.com/admin/realms/master/users").to_return(
      headers: {
        Location: "http://keycloak.example.com/amin/relms/master/users/42"
      }
    )

    post account_path, params: {
      account: {
        account_id:            "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell"
      }
    }

    assert_redirected_to root_path

    assert_requested :post, "http://keycloak.example.com/admin/realms/master/users", **{
      body: {
        username:  "alice",
        firstName: "Alice",
        lastName:  "Liddell",
        email:     "alice@example.com",
        enabled:   true,

        attributes: {
          middleName:          [],
          firstNameJapanese:   [],
          lastNameJapanese:    [],
          institution:         [],
          institutionJapanese: [],
          labFacDep:           [],
          labFacDepJapanese:   [],
          url:                 [],
          country:             [],
          postalCode:          [],
          prefecture:          [],
          city:                [],
          street:              [],
          phone:               [],
          fax:                 [],
          lang:                [],
          jobTitle:            [],
          jobTitleJapanese:    [],
          orcid:               [],
          eradId:              [],
          sshKeys:             []
        },

        credentials: [
          type:      "password",
          temporary: false,
          value:     "P@ssw0rd"
        ]
      }
    }
  end
end
