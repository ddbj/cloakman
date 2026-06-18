require 'application_system_test_case'

class Admin::SSHKeysTest < ApplicationSystemTestCase
  setup do
    @ed25519 = file_fixture('ssh_keys/id_ed25519.pub').read.chomp

    sign_in FactoryBot.create(:user, :admin)
  end

  test 'ssh key added successfully' do
    user = FactoryBot.create(:user)

    visit new_admin_user_ssh_key_path(user)

    fill_in 'Key', with: @ed25519
    click_on 'Save'

    assert_selector '.alert', text: 'SSH key added successfully.'
    assert_text @ed25519
  end

  test 'ssh key deleted successfully' do
    user = FactoryBot.create(:user, ssh_keys: [@ed25519])

    visit admin_user_ssh_keys_path(user)

    within 'li', text: @ed25519 do
      click_on 'Delete'
    end

    assert_selector '.alert', text: 'SSH key deleted successfully.'
    assert_no_text @ed25519
  end
end
