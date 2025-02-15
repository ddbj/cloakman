require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user, password: "P@ssw0rd")
  end

  test "password updated successfully" do
    patch password_path, params: {
      form: {
        current_password:          "P@ssw0rd",
        new_password:              "P@ssw0rd2",
        new_password_confirmation: "P@ssw0rd2"
      }
    }

    assert_redirected_to edit_password_path
    follow_redirect!

    assert_dom ".alert", "Password updated successfully."
  end
end
