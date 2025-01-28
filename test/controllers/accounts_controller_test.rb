require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include IntegrationTestHelper

  setup do
    LDAP.connection.search base: ENV.fetch("LDAP_BASE_DN"), scope: Net::LDAP::SearchScope_SingleLevel do |entry|
      LDAP.connection.delete dn: entry.dn
    end

    REDIS.call :select, 1
    REDIS.call :flushdb
    REDIS.call :set, "uid_number", 1000
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

  test "profile updated successfully" do
    sign_in FactoryBot.create(:user)

    patch profile_path, params: {
      user: {
        email:        "bob@example.com",
        first_name:   "Bob",
        last_name:    "Martin",
        organization: "ACME",
        country:      "US",
        city:         "Springfield"
      }
    }

    assert_redirected_to edit_profile_path
  end

  test "profile update failed" do
    sign_in FactoryBot.create(:user)

    patch profile_path, params: {
      user: {
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
