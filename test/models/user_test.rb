require 'test_helper'

using LDAPAssertion

class UserTest < ActiveSupport::TestCase
  test 'create' do
    FactoryBot.create :user, **{
      id:             'alice',
      first_name:     'Alice',
      last_name:      'Liddell',
      uid_number:     1001,
      gid_number:     1002,
      home_directory: '/home/alice',
      login_shell:    '/bin/bash'
    }

    entry = ExtLDAP.connection.assert_call(:search, **{
      base:  'uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org',
      scope: Net::LDAP::SearchScope_BaseObject
    }).first

    assert_equal ['Alice Liddell'], entry[:cn]
    assert_equal ['1001'],          entry[:uidNumber]
    assert_equal ['1002'],          entry[:gidNumber]
    assert_equal ['/home/alice'],   entry[:homeDirectory]
    assert_equal ['/bin/bash'],     entry[:loginShell]
  end

  test 'create (already exists in ext ldap)' do
    ExtLDAP.connection.assert_call :add, **{
      dn: 'uid=alice,ou=users,ou=test,dc=example,dc=org',

      attributes: {
        objectClass:   ['account', 'posixAccount'],
        uid:           ['alice'],
        cn:            ['Alice Liddell'],
        uidNumber:     ['1001'],
        gidNumber:     ['1002'],
        homeDirectory: ['/home/alice'],
        loginShell:    ['/bin/bash']
      }
    }

    FactoryBot.create :user, id: 'alice'

    assert_raises LDAPError::NoSuchObject do
      ExtLDAP.connection.assert_call(:search, **{
        base:  'uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org',
        scope: Net::LDAP::SearchScope_BaseObject
      })
    end
  end

  test 'update' do
    user = FactoryBot.create(:user, id: 'alice')

    user.update!(
      first_name:     'Alice',
      last_name:      'Liddell',
      uid_number:     1001,
      gid_number:     1002,
      home_directory: '/home/alice',
      login_shell:    '/bin/bash'
    )

    entry = ExtLDAP.connection.assert_call(:search, **{
      base:  'uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org',
      scope: Net::LDAP::SearchScope_BaseObject
    }).first

    assert_equal ['Alice Liddell'], entry[:cn]
    assert_equal ['1001'],          entry[:uidNumber]
    assert_equal ['1002'],          entry[:gidNumber]
    assert_equal ['/home/alice'],   entry[:homeDirectory]
    assert_equal ['/bin/bash'],     entry[:loginShell]
  end

  test 'update (already exists in ext ldap)' do
    ExtLDAP.connection.assert_call :add, **{
      dn: 'uid=alice,ou=users,ou=test,dc=example,dc=org',

      attributes: {
        objectClass:   ['account', 'posixAccount'],
        uid:           ['alice'],
        cn:            ['Alice Liddell'],
        uidNumber:     ['1001'],
        gidNumber:     ['1002'],
        homeDirectory: ['/home/alice'],
        loginShell:    ['/bin/bash']
      }
    }

    user = FactoryBot.create(:user, id: 'alice')

    user.update!(
      first_name:     'Alice',
      last_name:      'Liddell',
      uid_number:     1001,
      gid_number:     1002,
      home_directory: '/home/alice',
      login_shell:    '/bin/bash'
    )

    assert_raises LDAPError::NoSuchObject do
      ExtLDAP.connection.assert_call(:search, **{
        base:  'uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org',
        scope: Net::LDAP::SearchScope_BaseObject
      })
    end
  end

  test 'update (no ext entry)' do
    user = FactoryBot.create(:user, id: 'alice')

    ExtLDAP.connection.assert_call :delete, dn: 'uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org'

    user.update!

    assert_nothing_raised do
      ExtLDAP.connection.assert_call :search, **{
        base:  'uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org',
        scope: Net::LDAP::SearchScope_BaseObject
      }
    end
  end

  test 'destroy' do
    user = FactoryBot.create(:user, id: 'alice')
    user.destroy!

    assert_raises LDAPError::NoSuchObject do
      ExtLDAP.connection.assert_call :search, **{
        base:  'uid=alice,ou=cloakman-users,ou=test,dc=example,dc=org',
        scope: Net::LDAP::SearchScope_BaseObject
      }
    end
  end

  test 'uid_number auto increment' do
    FactoryBot.create :user, uid_number: 1001
    FactoryBot.create :user, uid_number: 1002

    REDIS.call :set, 'uid_number', 1000

    user = FactoryBot.create(:user)

    assert_equal 1003, user.uid_number
  end
end
