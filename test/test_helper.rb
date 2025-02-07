ENV["LDAP_ADMIN_DN"]       = "cn=admin,dc=example,dc=org"
ENV["LDAP_ADMIN_PASSWORD"] = "adminpassword"
ENV["LDAP_PORT"]           = "2636"
ENV["LDAP_USERS_DN"]       = "ou=users,dc=example,dc=org"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

Rails.root.glob("test/support/*.rb").each do
  require it
end
