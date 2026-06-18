require 'application_system_test_case'

class PasswordsTest < ApplicationSystemTestCase
  setup do
    sign_in FactoryBot.create(:user, password: 'P@ssw0rd')
  end

  test 'password updated successfully' do
    visit edit_password_path

    fill_in 'Current password',          with: 'P@ssw0rd'
    fill_in 'New password',              with: 'P@ssw0rd2'
    fill_in 'New password confirmation', with: 'P@ssw0rd2'

    click_on 'Update password'

    assert_selector '.alert', text: 'Password updated successfully.'
  end
end
