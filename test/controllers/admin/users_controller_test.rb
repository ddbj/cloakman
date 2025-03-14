require "test_helper"

using LDAPAssertion

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user, :admin)
  end

  test "index: search users" do
    FactoryBot.create :user, id: "alice"

    get admin_users_path, params: {
      form: {
        query: "alice"
      }
    }

    assert_response :ok

    assert_dom "tbody > tr", count: 1
    assert_dom "a", text: "alice"
  end

  test "new: user exists in external LDAP" do
    ExtLDAP.connection.assert_call :add, **{
      dn: "uid=alice,ou=users,#{ExtLDAP.base_dn}",

      attributes: {
        objectClass:   %w[account posixAccount],
        uid:           "alice",
        cn:            "Alice Liddell",
        uidNumber:     "2000",
        gidNumber:     "2001",
        homeDirectory: "/home/alice"
      }
    }

    get new_admin_user_path(
      user: {
        id: "alice"
      }
    )

    assert_response :ok

    assert_dom ".alert.alert-warning", "This user already exists in the external LDAP. The UID and GID will be set to match the existing entry."
  end

  test "create: ok" do
    REDIS.call :set, "uid_number", 2000

    post admin_users_path, params: {
      user: {
        id:                    "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "Wonderland",
        country:               "GB",
        city:                  "Daresbury",
        inet_user_status:      "active",
        account_type_number:   "general"
      }
    }

    assert_redirected_to admin_users_path

    user = User.find("alice")

    assert_equal "alice@example.com", user.email
    assert_equal "Alice",             user.first_name
    assert_equal "Liddell",           user.last_name
    assert_equal "Wonderland",        user.organization
    assert_equal "GB",                user.country
    assert_equal "Daresbury",         user.city
    assert_equal "active",            user.inet_user_status
    assert_equal "general",           user.account_type_number
    assert_equal 2001,                user.uid_number
    assert_equal 61000,               user.gid_number
  end

  test "create: user exists in external LDAP" do
    ExtLDAP.connection.assert_call :add, **{
      dn: "uid=alice,ou=users,#{ExtLDAP.base_dn}",

      attributes: {
        objectClass:   %w[account posixAccount],
        uid:           "alice",
        cn:            "Alice Liddell",
        uidNumber:     "3000",
        gidNumber:     "3001",
        homeDirectory: "/home/alice"
      }
    }

    post admin_users_path, params: {
      user: {
        id:                    "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "Wonderland",
        country:               "GB",
        city:                  "Daresbury",
        inet_user_status:      "active",
        account_type_number:   "general"
      }
    }

    assert_redirected_to admin_users_path

    user = User.find("alice")

    assert_equal 3000, user.uid_number
    assert_equal 3001, user.gid_number
  end

  test "create: failed" do
    post admin_users_path, params: {
      user: {
        id:                    "alice",
        password:              "P@ssw0rd",
        password_confirmation: "P@ssw0rd123",
        email:                 "alice@example.com",
        first_name:            "Alice",
        last_name:             "Liddell",
        organization:          "Wonderland",
        country:               "GB",
        city:                  "Daresbury",
        inet_user_status:      "active",
        account_type_number:   "general"
      }
    }

    assert_response :unprocessable_content

    assert_dom ".invalid-feedback", text: "doesn't match Password"
  end

  test "update: ok" do
    user = FactoryBot.create(:user)

    patch admin_user_path(user), params: {
      user: {
        email:               "alice@example.com",
        first_name:          "Alice",
        last_name:           "Liddell",
        organization:        "Wonderland",
        country:             "GB",
        city:                "Daresbury",
        inet_user_status:    "inactive",
        account_type_number: "ddbj"
      }
    }

    assert_redirected_to admin_users_path

    user = User.find(user.id)

    assert_equal "alice@example.com", user.email
    assert_equal "Alice",             user.first_name
    assert_equal "Liddell",           user.last_name
    assert_equal "Wonderland",        user.organization
    assert_equal "GB",                user.country
    assert_equal "Daresbury",         user.city
    assert_equal "inactive",          user.inet_user_status
    assert_equal "ddbj",              user.account_type_number
  end

  test "update: failed" do
    user = FactoryBot.create(:user)

    patch admin_user_path(user), params: {
      user: {
        email:               "",
        first_name:          "Alice",
        last_name:           "Liddell",
        organization:        "Wonderland",
        country:             "GB",
        city:                "Daresbury",
        inet_user_status:    "inactive",
        account_type_number: "ddbj"
      }
    }

    assert_response :unprocessable_content
  end
end
