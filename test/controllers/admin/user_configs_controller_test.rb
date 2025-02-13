require "test_helper"

class Admin::UserConfigsControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user, :admin)
  end

  test "config updated successfully" do
    user = FactoryBot.create(:user)

    patch admin_user_config_path(user), params: {
      user: {
        inet_user_status:    "active",
        account_type_number: "ddbj"
      }
    }

    assert_redirected_to edit_admin_user_config_path(user)

    user = User.find(user.username)

    assert_equal "active", user.inet_user_status
    assert_equal "ddbj",   user.account_type_number
  end
end
