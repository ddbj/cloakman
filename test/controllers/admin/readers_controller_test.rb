require 'test_helper'

class Admin::ReadersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in FactoryBot.create(:user, :admin)
  end

  test 'reader details' do
    FactoryBot.create :reader, id: 'example'

    get admin_reader_path('example')

    assert_dom 'dd', text: 'ou=test,ou=users,dc=ddbj,dc=nig,dc=ac,dc=jp'
    assert_dom 'dd', text: 'uid=example,ou=test,ou=readers,dc=ddbj,dc=nig,dc=ac,dc=jp'
    assert_dom 'dd', text: '********'
  end

  test 'listing readers' do
    FactoryBot.create :reader, id: 'example'

    get admin_readers_path

    assert_response :ok

    assert_dom 'a', text: 'example'
  end

  test 'reader created successfully' do
    SecureRandom.stub :base58, 'notasecret' do
      post admin_readers_path, params: {
        reader: {
          id: 'example'
        }
      }
    end

    assert_redirected_to admin_reader_path('example')
    follow_redirect!

    assert_dom '.alert', 'Reader created successfully.'
    assert_dom 'dd', 'uid=example,ou=test,ou=readers,dc=ddbj,dc=nig,dc=ac,dc=jp'
    assert_dom 'dd', 'notasecret'
  end

  test 'reader creation failed' do
    post admin_readers_path, params: {
      reader: {
        id: ''
      }
    }

    assert_response :unprocessable_content

    assert_dom '.invalid-feedback', text: "can't be blank"
  end

  test 'reader deleted successfully' do
    FactoryBot.create :reader, id: 'example'

    delete admin_reader_path('example')

    assert_redirected_to admin_readers_path
    follow_redirect!

    assert_dom '.alert', 'Reader deleted successfully.'
  end
end
