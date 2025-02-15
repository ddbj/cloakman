require "test_helper"

class SSHKeysControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data
  end

  test "ssh key added successfully" do
    sign_in FactoryBot.create(:user)

    post ssh_keys_path, params: {
      form: {
        ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeQixPzoAx225l+gijOBH1TbwiU6zPqrJwClRUceY8P"
      }
    }

    assert_redirected_to ssh_keys_path
    follow_redirect!

    assert_dom ".alert", "SSH key added successfully."
    assert_match "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeQixPzoAx225l+gijOBH1TbwiU6zPqrJwClRUceY8P", response.body
  end

  test "ssh key deleted successfully" do
    sign_in FactoryBot.create(:user, **{
      ssh_keys: [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeQixPzoAx225l+gijOBH1TbwiU6zPqrJwClRUceY8P" ]
    })

    delete ssh_key_path(0)

    assert_redirected_to ssh_keys_path
    follow_redirect!

    assert_dom ".alert", "SSH key deleted successfully."
    assert_no_match "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeQixPzoAx225l+gijOBH1TbwiU6zPqrJwClRUceY8P", response.body
  end
end
