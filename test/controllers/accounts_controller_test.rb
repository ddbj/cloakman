require "test_helper"

using LDAPAssertion

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data
  end

  test "account created successfully" do
    post account_path, params: {
      user: {
        id:                    "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "Wonderland",
        country:               "GB",
        city:                  "Daresbury"
      }
    }

    assert_redirected_to root_path

    user = User.find("alice")

    assert_equal "alice",             user.id
    assert_equal "alice@example.com", user.email
    assert_equal "Alice",             user.first_name
    assert_equal "Liddell",           user.last_name
    assert_equal "Wonderland",        user.organization
    assert_equal "GB",                user.country
    assert_equal "Daresbury",         user.city
  end

  test "account creation failed" do
    post account_path, params: {
      user: {
        id:                    "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd123",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "Wonderland",
        country:               "GB",
        city:                  "Daresbury"
      }
    }

    assert_response :unprocessable_content

    assert_dom ".invalid-feedback", text: "doesn't match Password"
  end

  test "duplicate id with external LDAP are not allowed" do
    ExtLDAP.connection.assert_call :add, **{
      dn: "uid=alice,ou=people,#{ExtLDAP.base_dn}",

      attributes: {
        objectClass:   %w[account posixAccount],
        uid:           "alice",
        cn:            "Alice Liddell",
        uidNumber:     "1000",
        gidNumber:     "1000",
        homeDirectory: "/home/alice"
      }
    }

    post account_path, params: {
      user: {
        id:                    "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "Wonderland",
        country:               "GB",
        city:                  "Daresbury"
      }
    }

    assert_response :unprocessable_content

    assert_dom ".invalid-feedback", text: "has already been taken"
  end

  test "duplicate emails are not allowed" do
    FactoryBot.create :user, email: "alice@example.com"

    post account_path, params: {
      user: {
        id:                    "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "Wonderland",
        country:               "GB",
        city:                  "Daresbury"
      }
    }

    assert_response :unprocessable_content

    assert_dom ".invalid-feedback", text: "has already been taken"
  end
end
