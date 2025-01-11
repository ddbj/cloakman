require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelper

  setup do
    stub_token_request
  end

  test "account created successfully" do
    stub_request(:post, "http://keycloak.example.com/admin/realms/master/users").to_return(
      headers: {
        Location: "http://keycloak.example.com/amin/relms/master/users/42"
      }
    )

    post account_path, params: {
      account: {
        username:              "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "ACME",
        country:               "US",
        city:                  "Springfield"
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
          middleName:           [],
          firstNameJapanese:    [],
          lastNameJapanese:     [],
          organization:         [ "ACME" ],
          organizationJapanese: [],
          labFacDep:            [],
          labFacDepJapanese:    [],
          organizationURL:      [],
          country:              [ "US" ],
          postalCode:           [],
          prefecture:           [],
          city:                 [ "Springfield" ],
          street:               [],
          phone:                [],
          jobTitle:             [],
          jobTitleJapanese:     [],
          orcid:                [],
          eradID:               [],
          sshKeys:              []
        },

        credentials: [
          type:      "password",
          temporary: false,
          value:     "P@ssw0rd"
        ]
      }
    }
  end

  test "account creation failed" do
    post account_path, params: {
      account: {
        username:              "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd123",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "ACME",
        country:               "US",
        city:                  "Springfield"
      }
    }

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback", text: "doesn't match Password"
  end

  test "account updated successfully" do
    sign_in FactoryBot.create(:account, id: 42)

    stub_request :put, "http://keycloak.example.com/admin/realms/master/users/42"

    patch account_path, params: {
      account: {
        email:        "bob@example.com",
        first_name:   "Bob",
        last_name:    "Martin",
        organization: "ACME",
        country:      "US",
        city:         "Springfield"
      }
    }

    assert_redirected_to edit_account_path

    assert_requested :put, "http://keycloak.example.com/admin/realms/master/users/42", **{
      body: {
        firstName: "Bob",
        lastName:  "Martin",
        email:     "bob@example.com",

        attributes: {
          middleName:           [],
          firstNameJapanese:    [],
          lastNameJapanese:     [],
          organization:         [ "ACME" ],
          organizationJapanese: [],
          labFacDep:            [],
          labFacDepJapanese:    [],
          organizationURL:      [],
          country:              [ "US" ],
          postalCode:           [],
          prefecture:           [],
          city:                 [ "Springfield" ],
          street:               [],
          phone:                [],
          jobTitle:             [],
          jobTitleJapanese:     [],
          orcid:                [],
          eradID:               [],
          sshKeys:              []
        }
      }
    }
  end

  test "account update failed" do
    sign_in FactoryBot.create(:account)

    patch account_path, params: {
      account: {
        email:        "",
        first_name:   "Bob",
        last_name:    "Martin",
        organization: "ACME",
        country:      "US",
        city:         "Springfield"
      }
    }

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback", text: "can't be blank"
  end
end
