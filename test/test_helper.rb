ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

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

require 'minitest/mock'

OmniAuth.config.test_mode = true
