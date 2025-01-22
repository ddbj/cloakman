require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  def sign_in(user)
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |jar|
      jar.signed[:session_id] = Current.session.id
      cookies[:session_id]    = jar[:session_id]
    end
  end

  test "account created successfully" do
    post account_path, params: {
      account: {
        username: "alice",

        user_attributes: {
          password:              "P@ssw0rd",
          password_confirmation: "P@ssw0rd",
          email:                 "alice@example.com",
          first_name:            "Alice",
          last_name:             "Liddell",
          organization:          "ACME",
          country:               "US",
          city:                  "Springfield"
        }
      }
    }

    assert_redirected_to new_session_path

    user = User.last

    assert_equal "alice",             user.account.username
    assert_equal "Alice",             user.first_name
    assert_equal "Liddell",           user.last_name
    assert_equal "alice@example.com", user.email
    assert_equal "ACME",              user.organization
    assert_equal "US",                user.country
    assert_equal "Springfield",       user.city

    assert user.authenticate("P@ssw0rd")
  end

  test "account creation failed" do
    post account_path, params: {
      account: {
        username: "alice",

        user_attributes: {
          password:              "P@ssw0rd",
          password_confirmation: "P@ssw0rd123",
          email:                 "alice@example.com",
          first_name:            "Alice",
          last_name:             "Liddell",
          organization:          "ACME",
          country:               "US",
          city:                  "Springfield"
        }
      }
    }

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback", text: "doesn't match Password"
  end

  test "account updated successfully" do
    sign_in users(:ursm)

    patch account_path, params: {
      account: {
        user_attributes: {
          id:           users(:ursm).id,
          email:        "bob@example.com",
          first_name:   "Bob",
          last_name:    "Martin",
          organization: "ACME",
          country:      "US",
          city:         "Springfield"
        }
      }
    }

    assert_redirected_to edit_account_path

    user = User.last

    assert_equal "Bob",             user.first_name
    assert_equal "Martin",          user.last_name
    assert_equal "bob@example.com", user.email
    assert_equal "ACME",            user.organization
    assert_equal "US",              user.country
    assert_equal "Springfield",     user.city
  end

  test "account update failed" do
    sign_in users(:ursm)

    patch account_path, params: {
      account: {
        user_attributes: {
          email:        "",
          first_name:   "Bob",
          last_name:    "Martin",
          organization: "ACME",
          country:      "US",
          city:         "Springfield"
        }
      }
    }

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback", text: "can't be blank"
  end
end
