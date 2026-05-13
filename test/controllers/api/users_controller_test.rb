require 'test_helper'

class API::UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should list active users' do
    FactoryBot.create :user, id: 'alice',   first_name: 'Alice',   last_name: 'Liddell',  organization: 'Wonderland'
    FactoryBot.create :user, id: 'bob',     first_name: 'Bob',     last_name: 'Builder',  organization: 'Construction Co'
    FactoryBot.create :user, id: 'charlie', first_name: 'Charlie', last_name: 'Chaplin',  organization: 'Silent Films', inet_user_status: :inactive

    get api_users_path, headers: {Authorization: 'Bearer TOKEN_ONE'}

    assert_response :ok

    res = JSON.parse(response.body, symbolize_names: true)

    assert_equal %w[alice bob], res.pluck(:uid)
    assert_equal({
      uid:                 'alice',
      full_name:           'Alice Liddell',
      email:               'alice@example.com',
      organization:        'Wonderland',
      account_type_number: 'general'
    }, res.first)
  end

  test 'filters users by query' do
    FactoryBot.create :user, id: 'alice', first_name: 'Alice', last_name: 'Liddell'
    FactoryBot.create :user, id: 'bob',   first_name: 'Bob',   last_name: 'Builder'

    get api_users_path, params: {query: 'ali'}, headers: {Authorization: 'Bearer TOKEN_ONE'}

    assert_response :ok

    res = JSON.parse(response.body, symbolize_names: true)

    assert_equal %w[alice], res.pluck(:uid)
  end

  test 'rejects unauthenticated requests to index' do
    get api_users_path

    assert_response :unauthorized
  end

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
