class Keycloak
  class Admin
    def initialize(client, realm)
      @client = client
      @realm  = realm
    end

    %i[get post put patch delete].each do |method|
      define_method method do |path, *args, **kwargs, &block|
        access_token.public_send(method, "/admin/realms/#{@realm}/#{path}", *args, snaky: false, **kwargs, &block)
      end
    end

    private

    def access_token
      @client.client_credentials.get_token
    end
  end

  include Singleton

  def initialize
    client_id, client_secret, url, @realm = ENV.values_at(
      "KEYCLOAK_CLIENT_ID",
      "KEYCLOAK_CLIENT_SECRET",
      "KEYCLOAK_URL",
      "KEYCLOAK_REALM"
    )

    @client = OAuth2::Client.new(client_id, client_secret, **{
      site:              "#{url}/realms/#{@realm}",
      authorization_url: "protocol/openid-connect/auth",
      token_url:         "protocol/openid-connect/token"
    })

    @admin = Admin.new(@client, @realm)
  end

  attr_reader :admin
  attr_reader :client
end
