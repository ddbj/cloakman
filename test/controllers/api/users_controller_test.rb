require 'test_helper'

class API::UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should create user' do
    post api_users_path, **{
      headers: {
        Authorization: 'Bearer TOKEN_ONE'
      },

      params: {
        user: {
          id:           'alice',
          password:     'P@ssw0rd',
          email:        'alice@example.com',
          first_name:   'Alice',
          last_name:    'Liddell',
          organization: 'Wonderland',
          country:      'GB',
          city:         'Oxford'
        }
      }
    }

    assert_response :created
  end

  test 'validates presence of email' do
    post api_users_path, **{
      headers: {
        Authorization: 'Bearer TOKEN_ONE'
      },

      params: {
        user: {
          id:           'alice',
          password:     'p@ssw0rd',
          email:        '',
          first_name:   'Alice',
          last_name:    'Liddell',
          organization: 'Wonderland',
          country:      'GB',
          city:         'Oxford'
        }
      }
    }

    assert_response :unprocessable_content

    res = JSON.parse(response.body, symbolize_names: true)

    assert_equal({email: ["can't be blank"]}, res[:errors])
  end
end
