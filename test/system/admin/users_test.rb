require 'application_system_test_case'

using LDAPAssertion

class Admin::UsersTest < ApplicationSystemTestCase
  setup do
    sign_in FactoryBot.create(:user, :admin)
  end

  test 'index: search users' do
    FactoryBot.create :user, id: 'alice'

    visit admin_users_path(form: {query: 'alice'})

    assert_selector 'tbody > tr', count: 1
    assert_selector 'a', text: 'alice'
  end

  test 'new: user exists in external LDAP' do
    ExtLDAP.connection.assert_call :add, **{
      dn: "uid=alice,ou=users,#{ExtLDAP.base_dn}",

      attributes: {
        objectClass:   %w[account posixAccount],
        uid:           'alice',
        cn:            'Alice Liddell',
        uidNumber:     '2000',
        gidNumber:     '2001',
        homeDirectory: '/home/alice'
      }
    }

    visit new_admin_user_path(user: {id: 'alice'})

    assert_selector '.alert.alert-warning', text: 'This user already exists in the external LDAP. The UID and GID will be set to match the existing entry.'
  end

  test 'create: ok' do
    REDIS.call :set, 'uid_number', 2000

    visit new_admin_user_path

    fill_in 'Username',              with: 'alice'
    fill_in 'Password',              with: 'P@ssw0rd'
    fill_in 'Password confirmation', with: 'P@ssw0rd'
    fill_in 'Email',                 with: 'alice@example.com'
    fill_in 'First name',            with: 'Alice'
    fill_in 'Last name',             with: 'Liddell'
    fill_in 'Organization',          with: 'Wonderland'
    select  'United Kingdom',        from: 'Country'
    fill_in 'City',                  with: 'Daresbury'

    select 'Active',  from: 'Status'
    select 'General', from: 'Account type'

    click_on 'Create User'

    assert_current_path admin_users_path

    user = User.find('alice')

    assert_equal 'alice@example.com', user.email
    assert_equal 'Alice',             user.first_name
    assert_equal 'Liddell',           user.last_name
    assert_equal 'Wonderland',        user.organization
    assert_equal 'GB',                user.country
    assert_equal 'Daresbury',         user.city
    assert_equal 'active',            user.inet_user_status
    assert_equal 'general',           user.account_type_number
    assert_equal 2001,                user.uid_number
    assert_equal 1234,                user.gid_number
  end

  test 'create: user exists in external LDAP' do
    ExtLDAP.connection.assert_call :add, **{
      dn: "uid=alice,ou=users,#{ExtLDAP.base_dn}",

      attributes: {
        objectClass:   %w[account posixAccount],
        uid:           'alice',
        cn:            'Alice Liddell',
        uidNumber:     '3000',
        gidNumber:     '3001',
        homeDirectory: '/home/alice'
      }
    }

    visit new_admin_user_path

    fill_in 'Username',              with: 'alice'
    fill_in 'Password',              with: 'P@ssw0rd'
    fill_in 'Password confirmation', with: 'P@ssw0rd'
    fill_in 'Email',                 with: 'alice@example.com'
    fill_in 'First name',            with: 'Alice'
    fill_in 'Last name',             with: 'Liddell'
    fill_in 'Organization',          with: 'Wonderland'
    select  'United Kingdom',        from: 'Country'
    fill_in 'City',                  with: 'Daresbury'

    select 'Active',  from: 'Status'
    select 'General', from: 'Account type'

    click_on 'Create User'

    assert_current_path admin_users_path

    user = User.find('alice')

    assert_equal 3000, user.uid_number
    assert_equal 3001, user.gid_number
  end

  test 'create: failed' do
    visit new_admin_user_path

    fill_in 'Username',              with: 'alice'
    fill_in 'Password',              with: 'P@ssw0rd'
    fill_in 'Password confirmation', with: 'P@ssw0rd123'
    fill_in 'Email',                 with: 'alice@example.com'
    fill_in 'First name',            with: 'Alice'
    fill_in 'Last name',             with: 'Liddell'
    fill_in 'Organization',          with: 'Wonderland'
    select  'United Kingdom',        from: 'Country'
    fill_in 'City',                  with: 'Daresbury'

    select 'Active',  from: 'Status'
    select 'General', from: 'Account type'

    click_on 'Create User'

    assert_selector '.invalid-feedback', text: "doesn't match Password"
  end

  test 'update: ok' do
    user = FactoryBot.create(:user)

    visit edit_admin_user_path(user)

    fill_in 'Email',        with: 'alice@example.com'
    fill_in 'First name',   with: 'Alice'
    fill_in 'Last name',    with: 'Liddell'
    fill_in 'Organization', with: 'Wonderland'
    select  'United Kingdom', from: 'Country'
    fill_in 'City',         with: 'Daresbury'

    select 'Inactive', from: 'Status'
    select 'DDBJ',     from: 'Account type'

    click_on 'Update User'

    assert_current_path admin_users_path

    user = User.find(user.id)

    assert_equal 'alice@example.com', user.email
    assert_equal 'Alice',             user.first_name
    assert_equal 'Liddell',           user.last_name
    assert_equal 'Wonderland',        user.organization
    assert_equal 'GB',                user.country
    assert_equal 'Daresbury',         user.city
    assert_equal 'inactive',          user.inet_user_status
    assert_equal 'ddbj',              user.account_type_number
  end

  test 'update: failed' do
    user = FactoryBot.create(:user)

    visit edit_admin_user_path(user)

    fill_in 'Email', with: ''

    click_on 'Update User'

    assert_selector '.invalid-feedback', text: "can't be blank"
  end
end
