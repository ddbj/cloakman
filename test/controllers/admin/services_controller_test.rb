require "test_helper"

class Admin::ServicesControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user, :admin)
  end

  test "listing service" do
    FactoryBot.create :service, username: "example"

    get admin_services_path

    assert_response :ok

    assert_select "a", text: "example"
  end

  test "service created successfully" do
    Base58.stub :binary_to_base58, "notasecret" do
      post admin_services_path, params: {
        service: {
          username: "example"
        }
      }
    end

    assert_redirected_to admin_service_path("example")

    service = Service.find("example")

    assert_equal "example",    service.username
    assert_equal "notasecret", service.password
  end

  test "service creation failed" do
    post admin_services_path, params: {
      service: {
        username: ""
      }
    }

    assert_response :unprocessable_content

    assert_select ".invalid-feedback", text: "can't be blank"
  end

  test "service deleted successfully" do
    FactoryBot.create :service, username: "example"

    delete admin_service_path("example")

    assert_redirected_to admin_services_path
  end
end
