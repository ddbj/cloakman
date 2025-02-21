require "test_helper"

class SSHKeysControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    @ed25519 = file_fixture("ssh_keys/id_ed25519.pub").read.chomp
  end

  test "ssh key added successfully" do
    sign_in FactoryBot.create(:user)

    post ssh_keys_path, params: {
      form: {
        ssh_key: @ed25519
      }
    }

    assert_redirected_to ssh_keys_path
    follow_redirect!

    assert_dom ".alert", "SSH key added successfully."
    assert_match @ed25519, response.body
  end

  test "ssh key deleted successfully" do
    sign_in FactoryBot.create(:user, **{
      ssh_keys: [ @ed25519 ]
    })

    delete ssh_key_path(0)

    assert_redirected_to ssh_keys_path
    follow_redirect!

    assert_dom ".alert", "SSH key deleted successfully."
    assert_no_match @ed25519, response.body
  end

  test "dsa keys are not permitted" do
    sign_in FactoryBot.create(:user)

    post ssh_keys_path, params: {
      form: {
        ssh_key: file_fixture("ssh_keys/id_dsa.pub").read.chomp
      }
    }

    assert_response :unprocessable_content

    assert_dom ".invalid-feedback", "DSA keys are not permitted. Please use RSA, ECDSA, or ED25519 keys instead."
  end
end
