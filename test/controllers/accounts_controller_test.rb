require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data
  end

  test "account created successfully" do
    post account_path, params: {
      user: {
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

    user = User.find("alice")

    assert_equal "alice",             user.username
    assert_equal "alice@example.com", user.email
    assert_equal "Alice",             user.first_name
    assert_equal "Liddell",           user.last_name
    assert_equal "ACME",              user.organization
    assert_equal "US",                user.country
    assert_equal "Springfield",       user.city
  end

  test "account creation failed" do
    post account_path, params: {
      user: {
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

  test "duplicate usernames with external LDAP are not allowed" do
    post account_path, params: {
      user: {
        username:              "user01",
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

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback", text: "has already been taken"
  end

  test "duplicate emails are not allowed" do
    FactoryBot.create :user, username: "bob", email: "bob@example.com"

    post account_path, params: {
      user: {
        username:              "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd",
        email:                 "bob@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "ACME",
        country:               "US",
        city:                  "Springfield"
      }
    }

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback", text: "has already been taken"
  end
end
