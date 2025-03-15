require "test_helper"

class Admin::SSHKeysControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    @ed25519 = file_fixture("ssh_keys/id_ed25519.pub").read.chomp

    sign_in FactoryBot.create(:user, :admin)
  end

  test "ssh key added successfully" do
    user = FactoryBot.create(:user)

    post admin_user_ssh_keys_path(user), params: {
      form: {
        ssh_key: @ed25519
      }
    }

    assert_redirected_to admin_user_ssh_keys_path(user)
    follow_redirect!

    assert_dom ".alert", "SSH key added successfully."
    assert_match @ed25519, response.body
  end

  test "ssh key deleted successfully" do
    user = FactoryBot.create(:user, **{
      ssh_keys: [ @ed25519 ]
    })

    delete admin_user_ssh_key_path(user, 0)

    assert_redirected_to admin_user_ssh_keys_path(user)
    follow_redirect!

    assert_dom ".alert", "SSH key deleted successfully."
    assert_no_match @ed25519, response.body
  end
end
