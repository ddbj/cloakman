require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data
  end

  test "user created successfully" do
    sign_in FactoryBot.create(:user, :admin)

    post admin_users_path, params: {
      user: {
        username:              "bob",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd",
        email:                 "bob@example.com",
        first_name:            "Bob",
        last_name:             "Martin",
        organization:          "ACME",
        country:               "US",
        city:                  "Springfield"
      }
    }

    assert_redirected_to new_admin_user_path
  end

  test "user creation failed" do
    sign_in FactoryBot.create(:user, :admin)

    post admin_users_path, params: {
      user: {
        username:              "bob",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd123",
        email:                 "bob@example.com",
        first_name:            "Bob",
        last_name:             "Martin",
        organization:          "ACME",
        country:               "US",
        city:                  "Springfield"
      }
    }

    assert_response :unprocessable_content

    assert_select ".invalid-feedback", text: "doesn't match Password"
  end

  test "can not access as normal user" do
    sign_in FactoryBot.create(:user)

    get new_admin_user_path

    assert_response :forbidden
  end
end
