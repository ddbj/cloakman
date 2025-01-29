require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user, :admin)
  end

  test "user created successfully" do
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

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback", text: "doesn't match Password"
  end
end
