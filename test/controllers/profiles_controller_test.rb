require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user)
  end

  test "profile updated successfully" do
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

  test "duplicate emails are not allowed" do
    FactoryBot.create :user, username: "bob", email: "bob@example.com"

    patch profile_path, params: {
      user: {
        email:        "bob@example.com",
        first_name:   "Alice",
        last_name:    "Liddell",
        organization: "Wonderland",
        country:      "GB",
        city:         "Daresbury"
      }
    }

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback", text: "has already been taken"
  end
end
