require "test_helper"

using LDAPAssertion

class UserTest < ActiveSupport::TestCase
  include TestHelper

  setup do
    reset_data
  end

  test "create" do
    FactoryBot.create :user, **{
      id:             "alice",
      first_name:     "Alice",
      last_name:      "Liddell",
      uid_number:     1001,
      gid_number:     1002,
      home_directory: "/home/alice",
      login_shell:    "/bin/bash"
    }

    entry = ExtLDAP.connection.assert_call(:search, **{
      base:  "uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org",
      scope: Net::LDAP::SearchScope_BaseObject
    }).first

    assert_equal [ "Alice Liddell" ], entry[:cn]
    assert_equal [ "1001" ],          entry[:uidNumber]
    assert_equal [ "1002" ],          entry[:gidNumber]
    assert_equal [ "/home/alice" ],   entry[:homeDirectory]
    assert_equal [ "/bin/bash" ],     entry[:loginShell]
  end

  test "update" do
    user = FactoryBot.create(:user, id: "alice")

    user.update!(
      first_name:     "Alice",
      last_name:      "Liddell",
      uid_number:     1001,
      gid_number:     1002,
      home_directory: "/home/alice",
      login_shell:    "/bin/bash"
    )

    entry = ExtLDAP.connection.assert_call(:search, **{
      base:  "uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org",
      scope: Net::LDAP::SearchScope_BaseObject
    }).first

    assert_equal [ "Alice Liddell" ], entry[:cn]
    assert_equal [ "1001" ],          entry[:uidNumber]
    assert_equal [ "1002" ],          entry[:gidNumber]
    assert_equal [ "/home/alice" ],   entry[:homeDirectory]
    assert_equal [ "/bin/bash" ],     entry[:loginShell]
  end

  test "update (no ext entry)" do
    user = FactoryBot.create(:user, id: "alice")

    ExtLDAP.connection.assert_call :delete, dn: "uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org"

    user.update!

    assert_nothing_raised do
      ExtLDAP.connection.assert_call :search, **{
        base:  "uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org",
        scope: Net::LDAP::SearchScope_BaseObject
      }
    end
  end

  test "destroy" do
    user = FactoryBot.create(:user, id: "alice")
    user.destroy!

    assert_raises LDAPError::NoSuchObject do
      ExtLDAP.connection.assert_call :search, **{
        base:  "uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org",
        scope: Net::LDAP::SearchScope_BaseObject
      }
    end
  end

  test "uid_number auto increment" do
    FactoryBot.create :user, uid_number: 1001
    FactoryBot.create :user, uid_number: 1002

    REDIS.call :set, "uid_number", 1000

    user = FactoryBot.create(:user)

    assert_equal 1003, user.uid_number
  end
end
