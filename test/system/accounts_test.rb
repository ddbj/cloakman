require 'application_system_test_case'

using LDAPAssertion

class AccountsTest < ApplicationSystemTestCase
  test 'account created successfully' do
    visit new_account_path

    fill_in 'Username',              with: 'alice'
    fill_in 'Password',              with: 'P@ssw0rd'
    fill_in 'Password confirmation', with: 'P@ssw0rd'
    fill_in 'Email',                 with: 'alice@example.com'
    fill_in 'First name',            with: 'Alice'
    fill_in 'Last name',             with: 'Liddell'
    fill_in 'Organization',          with: 'Wonderland'
    select  'United Kingdom',        from: 'Country'
    fill_in 'City',                  with: 'Daresbury'

    check 'I have read and agree to the Terms of Use.'

    click_on 'Create Account'

    assert_current_path root_path

    user = User.find('alice')

    assert_equal 'alice',             user.id
    assert_equal 'alice@example.com', user.email
    assert_equal 'Alice',             user.first_name
    assert_equal 'Liddell',           user.last_name
    assert_equal 'Wonderland',        user.organization
    assert_equal 'GB',                user.country
    assert_equal 'Daresbury',         user.city
  end

  test 'account creation failed' do
    visit new_account_path

    fill_in 'Username',              with: 'alice'
    fill_in 'Password',              with: 'P@ssw0rd'
    fill_in 'Password confirmation', with: 'P@ssw0rd123'
    fill_in 'Email',                 with: 'alice@example.com'
    fill_in 'First name',            with: 'Alice'
    fill_in 'Last name',             with: 'Liddell'
    fill_in 'Organization',          with: 'Wonderland'
    select  'United Kingdom',        from: 'Country'
    fill_in 'City',                  with: 'Daresbury'

    check 'I have read and agree to the Terms of Use.'

    click_on 'Create Account'

    assert_selector '.invalid-feedback', text: "doesn't match Password"
  end

  test 'duplicate id with external LDAP are not allowed' do
    ExtLDAP.connection.assert_call :add, **{
      dn: "uid=alice,ou=users,#{ExtLDAP.base_dn}",

      attributes: {
        objectClass:   %w[account posixAccount],
        uid:           'alice',
        cn:            'Alice Liddell',
        uidNumber:     '1000',
        gidNumber:     '1000',
        homeDirectory: '/home/alice'
      }
    }

    visit new_account_path

    fill_in 'Username',              with: 'alice'
    fill_in 'Password',              with: 'P@ssw0rd'
    fill_in 'Password confirmation', with: 'P@ssw0rd'
    fill_in 'Email',                 with: 'alice@example.com'
    fill_in 'First name',            with: 'Alice'
    fill_in 'Last name',             with: 'Liddell'
    fill_in 'Organization',          with: 'Wonderland'
    select  'United Kingdom',        from: 'Country'
    fill_in 'City',                  with: 'Daresbury'

    check 'I have read and agree to the Terms of Use.'

    click_on 'Create Account'

    assert_selector '.invalid-feedback', text: 'has already been taken'
  end

  test 'duplicate emails are not allowed' do
    FactoryBot.create :user, email: 'alice@example.com'

    visit new_account_path

    fill_in 'Username',              with: 'alice'
    fill_in 'Password',              with: 'P@ssw0rd'
    fill_in 'Password confirmation', with: 'P@ssw0rd'
    fill_in 'Email',                 with: 'alice@example.com'
    fill_in 'First name',            with: 'Alice'
    fill_in 'Last name',             with: 'Liddell'
    fill_in 'Organization',          with: 'Wonderland'
    select  'United Kingdom',        from: 'Country'
    fill_in 'City',                  with: 'Daresbury'

    check 'I have read and agree to the Terms of Use.'

    click_on 'Create Account'

    assert_selector '.invalid-feedback', text: 'has already been taken'
  end
end
