require "test_helper"

class SSHKeysControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user)
  end

  test "ssh key added successfully" do
    post ssh_keys_path, params: {
      form: {
        ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeQixPzoAx225l+gijOBH1TbwiU6zPqrJwClRUceY8P"
      }
    }

    assert_redirected_to ssh_keys_path
  end
end
