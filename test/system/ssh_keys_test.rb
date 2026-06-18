require 'application_system_test_case'

class SSHKeysTest < ApplicationSystemTestCase
  setup do
    @ed25519 = file_fixture('ssh_keys/id_ed25519.pub').read.chomp
  end

  test 'ssh key added successfully' do
    sign_in FactoryBot.create(:user)

    visit ssh_keys_path

    click_on 'New SSH key'

    fill_in 'Key', with: @ed25519
    click_on 'Save'

    assert_selector '.alert', text: 'SSH key added successfully.'
    assert_text @ed25519
  end

  test 'ssh key deleted successfully' do
    sign_in FactoryBot.create(:user, ssh_keys: [@ed25519])

    visit ssh_keys_path

    within 'li', text: @ed25519 do
      click_on 'Delete'
    end

    assert_selector '.alert', text: 'SSH key deleted successfully.'
    assert_no_text @ed25519
  end

  test 'dsa keys are not permitted' do
    sign_in FactoryBot.create(:user)

    visit new_ssh_key_path

    fill_in 'Key', with: file_fixture('ssh_keys/id_dsa.pub').read.chomp
    click_on 'Save'

    assert_selector '.invalid-feedback', text: 'DSA keys are not permitted. Please use RSA, ECDSA, or ED25519 keys instead.'
  end

  test 'weak rsa keys are not permitted' do
    sign_in FactoryBot.create(:user)

    visit new_ssh_key_path

    fill_in 'Key', with: file_fixture('ssh_keys/id_rsa_1024bit.pub').read.chomp
    click_on 'Save'

    assert_selector '.invalid-feedback', text: 'RSA keys must be at least 2048 bits long.'
  end
end
