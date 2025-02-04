require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data
  end

  test "accessing a protected page after signing in" do
    sign_in FactoryBot.create(:user)

    get edit_profile_path

    assert_response :ok
  end

  test "accessing a protected page without signing in" do
    get edit_profile_path

    assert_redirected_to root_path
  end

  test "non-active users cannot log in" do
    user = FactoryBot.create(:user, inet_user_status: "inactive")

    sign_in user
    get edit_profile_path

    assert_redirected_to root_path
  end

  test "accessing a protected page as an admin" do
    sign_in FactoryBot.create(:user, :admin)

    get admin_users_path

    assert_response :ok
  end

  test "accessing a protected page as a non-admin" do
    sign_in FactoryBot.create(:user)

    get admin_users_path

    assert_response :forbidden
  end
end
