ENV["KEYCLOAK_REALM"]      = "master"
ENV["KEYCLOAK_URL"] = "http://keycloak.example.com"
ENV["LDAP_PORT"]    = "2389"

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
