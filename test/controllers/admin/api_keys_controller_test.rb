require "test_helper"

class Admin::APIKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in FactoryBot.create(:user, :admin)
  end

  test "index" do
    get admin_api_keys_url

    assert_response :ok

    assert_dom "a", "Key 1"
  end

  test "show" do
    get admin_api_key_url(api_keys(:one))

    assert_response :ok

    assert_dom "h1", "Key 1"
  end

  test "new" do
    get new_admin_api_key_url

    assert_response :ok
  end

  test "create" do
    post admin_api_keys_url, params: {
      api_key: {
        name: "Key 2"
      }
    }

    assert_redirected_to admin_api_key_url(APIKey.last)
  end

  test "create with invalid data" do
    post admin_api_keys_url, params: {
      api_key: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
  end

  test "destroy" do
    delete admin_api_key_url(api_keys(:one))

    assert_redirected_to admin_api_keys_url
  end
end
