require 'application_system_test_case'

class Admin::APIKeysTest < ApplicationSystemTestCase
  setup do
    sign_in FactoryBot.create(:user, :admin)
  end

  test 'index' do
    visit admin_api_keys_path

    assert_selector 'a', text: 'Key 1'
  end

  test 'show' do
    visit admin_api_key_path(api_keys(:one))

    assert_selector 'h1', text: 'Key 1'
    assert_selector 'dd code', text: '********'
    assert_no_selector '.alert-danger'
  end

  test 'new' do
    visit new_admin_api_key_path

    assert_selector 'h1', text: 'New API Key'
  end

  test 'create' do
    visit new_admin_api_key_path

    fill_in 'Name', with: 'Key 2'
    click_on 'Create API Key'

    key = APIKey.find_by!(name: 'Key 2')

    assert_current_path admin_api_key_path(key)
    assert_selector '.alert-danger', text: 'will not be displayed again'
    assert_selector 'meta[name="turbo-cache-control"][content="no-cache"]', visible: :all
    assert_includes page.response_headers['Cache-Control'], 'no-store'

    token = find('dd code', text: /\A\w{24,}\z/).text

    assert_equal key, APIKey.authenticate(token)
    assert_text "Bearer #{token}"

    visit admin_api_key_path(key)

    assert_no_text token
    assert_selector 'dd code', text: '********'
  end

  test 'create with invalid data' do
    visit new_admin_api_key_path

    fill_in 'Name', with: ''
    click_on 'Create API Key'

    assert_selector '.invalid-feedback', text: "can't be blank"
  end

  test 'destroy' do
    visit admin_api_key_path(api_keys(:one))

    click_on 'Delete API Key'

    assert_current_path admin_api_keys_path
  end
end
