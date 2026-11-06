require 'test_helper'

# OmniAuth is mocked in the other tests, so this is the only one to parse a real HTTP response through
# the Faraday stack. A json and Faraday combination that couldn't parse it once broke every sign-in.
class OpenIDConnectDiscoveryTest < ActiveSupport::TestCase
  test 'parses the discovery document served by the identity provider' do
    with_discovery_server do |issuer|
      config = OpenIDConnect::Discovery::Provider::Config.discover!(issuer)

      assert_equal "#{issuer}/auth", config.authorization_endpoint
    end
  end

  private

  def with_discovery_server
    server = TCPServer.new('127.0.0.1', 0)
    issuer = "http://127.0.0.1:#{server.addr[1]}/realms/master"

    body = {
      issuer:,
      authorization_endpoint:                "#{issuer}/auth",
      jwks_uri:                              "#{issuer}/certs",
      response_types_supported:              %w[code],
      subject_types_supported:               %w[public],
      id_token_signing_alg_values_supported: %w[RS256]
    }.to_json

    thread = Thread.new {
      client = server.accept

      nil until client.gets.to_s.chomp.empty?

      client.write "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}"
      client.close
    }

    yield issuer
  ensure
    thread&.kill&.join
    server&.close
  end
end
