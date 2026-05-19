ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # LDAP and Redis are shared across workers, so parallel runs race on
    # reset_ldap (destroy/create) and reset_redis. Serialize to keep tests
    # deterministic.
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include LDAPTestHelper
    include RedisTestHelper
    include SessionTestHelper

    setup do
      reset_ldap
      reset_ext_ldap
      reset_redis
    end
  end
end

OmniAuth.config.test_mode = true
