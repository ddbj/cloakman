require 'application_system_test_case'

class Admin::ReadersTest < ApplicationSystemTestCase
  setup do
    sign_in FactoryBot.create(:user, :admin)
  end

  test 'reader details' do
    FactoryBot.create :reader, id: 'example'

    visit admin_reader_path('example')

    assert_selector 'dd', text: 'ou=test,ou=users,dc=ddbj,dc=nig,dc=ac,dc=jp'
    assert_selector 'dd', text: 'uid=example,ou=test,ou=readers,dc=ddbj,dc=nig,dc=ac,dc=jp'
    assert_selector 'dd', text: '********'
  end

  test 'listing readers' do
    FactoryBot.create :reader, id: 'example'

    visit admin_readers_path

    assert_selector 'a', text: 'example'
  end

  test 'reader created successfully' do
    visit new_admin_reader_path

    fill_in 'Username', with: 'example'

    SecureRandom.stub :base58, 'notasecret' do
      click_on 'Create Reader'
    end

    assert_current_path admin_reader_path('example')

    assert_selector '.alert', text: 'Reader created successfully.'
    assert_selector 'dd', text: 'uid=example,ou=test,ou=readers,dc=ddbj,dc=nig,dc=ac,dc=jp'
    assert_selector 'dd', text: 'notasecret'
  end

  test 'reader creation failed' do
    visit new_admin_reader_path

    fill_in 'Username', with: ''
    click_on 'Create Reader'

    assert_selector '.invalid-feedback', text: "can't be blank"
  end

  test 'reader deleted successfully' do
    FactoryBot.create :reader, id: 'example'

    visit admin_reader_path('example')

    click_on 'Delete Reader'

    assert_current_path admin_readers_path

    assert_selector '.alert', text: 'Reader deleted successfully.'
  end
end
