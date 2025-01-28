require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data
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
