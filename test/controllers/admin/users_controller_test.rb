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
        account_type_number:   1,
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
  end

  test "user creation failed" do
    post admin_users_path, params: {
      user: {
        account_type_number:   1,
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
        account_type_number: 3,
        email:               "alice@example.com",
        first_name:          "Alice",
        last_name:           "Liddell",
        organization:        "Wonderland",
        country:             "GB",
        city:                "Daresbury"
      }
    }

    assert_redirected_to admin_users_path
  end

  test "user update failed" do
    user = FactoryBot.create(:user)

    patch admin_user_path(user), params: {
      user: {
        account_type_number: 3,
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
