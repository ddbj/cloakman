require 'test_helper'

class APIKeyTest < ActiveSupport::TestCase
  test 'stores only the digest of a generated token' do
    key = FactoryBot.create(:api_key)

    assert_operator key.token.length, :>=, 24
    assert_equal APIKey.digest(key.token), key.token_digest
    assert_not_includes APIKey.column_names, 'token'
  end

  test 'authenticates with a token but not its digest' do
    key = FactoryBot.create(:api_key)

    assert_equal key, APIKey.authenticate(key.token)
    assert_nil APIKey.authenticate('invalid')
    assert_nil APIKey.authenticate(key.token_digest)
  end
end
