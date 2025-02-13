require "test_helper"

class Admin::UserProfilesControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user, :admin)
  end

  test "profile updated successfully" do
    user = FactoryBot.create(:user)

    patch admin_user_profile_path(user), params: {
      user: {
        email:               "alice@example.com",
        first_name:          "Alice",
        last_name:           "Liddell",
        organization:        "Wonderland",
        country:             "GB",
        city:                "Daresbury"
      }
    }

    assert_redirected_to edit_admin_user_profile_path(user)

    user = User.find(user.username)

    assert_equal "alice@example.com", user.email
    assert_equal "Alice",             user.first_name
    assert_equal "Liddell",           user.last_name
    assert_equal "Wonderland",        user.organization
    assert_equal "GB",                user.country
    assert_equal "Daresbury",         user.city
  end

  test "profile update failed" do
    user = FactoryBot.create(:user)

    patch admin_user_profile_path(user), params: {
      user: {
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
