OAuth2::Response.register_parser :json, "application/json" do |body|
  JSON.parse(body, symbolize_names: true)
end
