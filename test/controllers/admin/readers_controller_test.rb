require "test_helper"

class Admin::ReadersControllerTest < ActionDispatch::IntegrationTest
  include TestHelper

  setup do
    reset_data

    sign_in FactoryBot.create(:user, :admin)
  end

  test "reader details" do
    FactoryBot.create :reader, username: "example"

    get admin_reader_path("example")

    assert_select "dd", text: "ou=users,dc=example,dc=org"
    assert_select "dd", text: "uid=example,ou=readers,dc=example,dc=org"
    assert_select "dd", text: "********"
  end

  test "listing readers" do
    FactoryBot.create :reader, username: "example"

    get admin_readers_path

    assert_response :ok

    assert_select "a", text: "example"
  end

  test "reader created successfully" do
    Base58.stub :binary_to_base58, "notasecret" do
      post admin_readers_path, params: {
        reader: {
          username: "example"
        }
      }
    end

    assert_redirected_to admin_reader_path("example")

    follow_redirect!

    assert_select "dd", text: "uid=example,ou=readers,dc=example,dc=org"
    assert_select "dd", text: "notasecret"
  end

  test "reader creation failed" do
    post admin_readers_path, params: {
      reader: {
        username: ""
      }
    }

    assert_response :unprocessable_content

    assert_select ".invalid-feedback", text: "can't be blank"
  end

  test "reader deleted successfully" do
    FactoryBot.create :reader, username: "example"

    delete admin_reader_path("example")

    assert_redirected_to admin_readers_path
  end
end
