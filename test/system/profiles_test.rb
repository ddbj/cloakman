require 'application_system_test_case'

class ProfilesTest < ApplicationSystemTestCase
  setup do
    sign_in FactoryBot.create(:user)
  end

  test 'profile updated successfully' do
    visit edit_profile_path

    fill_in 'Email',        with: 'alice@example.com'
    fill_in 'First name',   with: 'Alice'
    fill_in 'Last name',    with: 'Liddell'
    fill_in 'Organization', with: 'Wonderland'
    select  'United Kingdom', from: 'Country'
    fill_in 'City',         with: 'Daresbury'

    click_on 'Update Profile'

    assert_current_path edit_profile_path
  end

  test 'profile update failed' do
    visit edit_profile_path

    fill_in 'Email',        with: ''
    fill_in 'First name',   with: 'Alice'
    fill_in 'Last name',    with: 'Liddell'
    fill_in 'Organization', with: 'Wonderland'
    select  'United Kingdom', from: 'Country'
    fill_in 'City',         with: 'Daresbury'

    click_on 'Update Profile'

    assert_selector '.invalid-feedback', text: "can't be blank"
  end

  test 'duplicate emails are not allowed' do
    FactoryBot.create :user, email: 'alice@example.com'

    visit edit_profile_path

    fill_in 'Email',        with: 'alice@example.com'
    fill_in 'First name',   with: 'Alice'
    fill_in 'Last name',    with: 'Liddell'
    fill_in 'Organization', with: 'Wonderland'
    select  'United Kingdom', from: 'Country'
    fill_in 'City',         with: 'Daresbury'

    click_on 'Update Profile'

    assert_selector '.invalid-feedback', text: 'has already been taken'
  end
end
