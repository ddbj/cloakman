require 'test_helper'

class AccountsTest < ActionDispatch::IntegrationTest
  VALID_PARAMS = {
    id:                    'alice',
    password:              'P@ssw0rd',
    password_confirmation: 'P@ssw0rd',
    email:                 'alice@example.com',
    first_name:            'Alice',
    last_name:             'Liddell',
    organization:          'Wonderland',
    country:               'GB',
    city:                  'Daresbury'
  }.freeze

  RETURN_TO = 'http://repository.example.com:4200/web/invitations/abc123'.freeze

  test 'a return address on a known application is honoured' do
    post account_path(return_to: RETURN_TO), params: {user: VALID_PARAMS}

    assert_redirected_to RETURN_TO
  end

  # It would not be displayed — they are leaving — and would then sit in
  # the session until their next visit, congratulating them on an account
  # they made last week.
  test 'leaving for another application carries no flash' do
    post account_path(return_to: RETURN_TO), params: {user: VALID_PARAMS}

    assert_nil flash[:notice]
  end

  test 'staying here does' do
    post account_path, params: {user: VALID_PARAMS}

    assert_match(/successfully created/, flash[:notice])
  end

  test 'no return address leaves them here' do
    post account_path, params: {user: VALID_PARAMS}

    assert_redirected_to root_path
  end

  # Ignored rather than refused: a link that cannot be followed back is
  # still a link that creates the account.
  test 'a return address anywhere else is ignored' do
    post account_path(return_to: 'http://evil.example.com/'), params: {user: VALID_PARAMS}

    assert_redirected_to root_path
  end

  test 'a host that merely starts like a known one is not a known one' do
    post account_path(return_to: 'http://repository.example.com.evil.example.com/'), params: {user: VALID_PARAMS}

    assert_redirected_to root_path
  end

  test 'a return address that is not a URL at all is ignored' do
    post account_path(return_to: 'javascript:alert(1)'), params: {user: VALID_PARAMS}

    assert_redirected_to root_path
  end

  # The form posts to its own URL, so nothing has to remember to carry the
  # return address across a validation error.
  test 'the return address survives a validation error' do
    post account_path(return_to: RETURN_TO),
         params: {user: VALID_PARAMS.merge(password_confirmation: 'mismatch')}

    assert_response :unprocessable_content
    assert_select 'form[action=?]', account_path(return_to: RETURN_TO)
  end

  # It parses with host `evil.example.com`, so the origin check refuses it
  # anyway — but an address whose whole purpose is to be misread has no
  # business in a redirect we vouch for.
  test 'a return address carrying userinfo is ignored' do
    post account_path(return_to: 'http://repository.example.com:4200@evil.example.com/'), params: {user: VALID_PARAMS}

    assert_redirected_to root_path
  end

  test 'a known origin with credentials in it is still ignored' do
    post account_path(return_to: 'http://user:pass@repository.example.com:4200/web/'), params: {user: VALID_PARAMS}

    assert_redirected_to root_path
  end

  test 'a protocol-relative address is ignored' do
    post account_path(return_to: '//evil.example.com/'), params: {user: VALID_PARAMS}

    assert_redirected_to root_path
  end
end
