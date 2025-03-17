require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in FactoryBot.create(:user)
  end

  test "profile updated successfully" do
    patch profile_path, params: {
      user: {
        email:        "alice@example.com",
        first_name:   "Alice",
        last_name:    "Liddell",
        organization: "Wonderland",
        country:      "GB",
        city:         "Daresbury"
      }
    }

    assert_redirected_to edit_profile_path
  end

  test "profile update failed" do
    patch profile_path, params: {
      user: {
        email:        "",
        first_name:   "Alice",
        last_name:    "Liddell",
        organization: "Wonderland",
        country:      "GB",
        city:         "Daresbury"
      }
    }

    assert_response :unprocessable_content

    assert_dom ".invalid-feedback", text: "can't be blank"
  end

  test "duplicate emails are not allowed" do
    FactoryBot.create :user, email: "alice@example.com"

    patch profile_path, params: {
      user: {
        email:        "alice@example.com",
        first_name:   "Alice",
        last_name:    "Liddell",
        organization: "Wonderland",
        country:      "GB",
        city:         "Daresbury"
      }
    }

    assert_response :unprocessable_content

    assert_dom ".invalid-feedback", text: "has already been taken"
  end
end
