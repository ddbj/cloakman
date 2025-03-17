require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "accessing a protected page after signing in" do
    sign_in FactoryBot.create(:user)

    get edit_profile_path

    assert_response :ok
  end

  test "accessing a protected page without signing in" do
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
