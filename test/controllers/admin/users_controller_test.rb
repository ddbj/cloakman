require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user, :admin)
  end

  test "search user" do
    FactoryBot.create :user, username: "alice"

    get admin_users_path, params: {
      query: "alice"
    }

    assert_response :ok

    assert_select "tbody > tr", count: 1
    assert_select "a", text: "alice"
  end

  test "user created successfully" do
    post admin_users_path, params: {
      user: {
        inet_user_status:      "active",
        account_type_number:   "general",
        username:              "alice",
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

    assert_redirected_to admin_users_path

    user = User.find("alice")

    assert_equal "active",            user.inet_user_status
    assert_equal "general",           user.account_type_number
    assert_equal "alice@example.com", user.email
    assert_equal "Alice",             user.first_name
    assert_equal "Liddell",           user.last_name
    assert_equal "Wonderland",        user.organization
    assert_equal "GB",                user.country
    assert_equal "Daresbury",         user.city
  end

  test "user creation failed" do
    post admin_users_path, params: {
      user: {
        inet_user_status:      "active",
        account_type_number:   "general",
        username:              "alice",
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

    assert_select ".invalid-feedback", text: "doesn't match Password"
  end

  test "user updated successfully" do
    user = FactoryBot.create(:user)

    patch admin_user_path(user), params: {
      user: {
        inet_user_status:    "inactive",
        account_type_number: "ddbj",
        email:               "alice@example.com",
        first_name:          "Alice",
        last_name:           "Liddell",
        organization:        "Wonderland",
        country:             "GB",
        city:                "Daresbury"
      }
    }

    assert_redirected_to admin_users_path

    user = User.find(user.username)

    assert_equal "inactive",          user.inet_user_status
    assert_equal "ddbj",              user.account_type_number
    assert_equal "alice@example.com", user.email
    assert_equal "Alice",             user.first_name
    assert_equal "Liddell",           user.last_name
    assert_equal "Wonderland",        user.organization
    assert_equal "GB",                user.country
    assert_equal "Daresbury",         user.city
  end

  test "user update failed" do
    user = FactoryBot.create(:user)

    patch admin_user_path(user), params: {
      user: {
        inet_user_status:    "inactive",
        account_type_number: "ddbj",
        email:               "",
        first_name:          "Alice",
        last_name:           "Liddell",
        organization:        "Wonderland",
        country:             "GB",
        city:                "Daresbury"
      }
    }

    assert_response :unprocessable_content
  end
end
