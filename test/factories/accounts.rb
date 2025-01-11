FactoryBot.define do
  factory :account do
    transient do
      sequence :id
    end

    username              { "alice" }
    password              { "P@ssw0rd" }
    password_confirmation { "P@ssw0rd" }
    email                 { "alice@examle.com" }
    first_name            { "Alice" }
    last_name             { "Liddell" }
    organization          { "Wonderland" }
    country               { "GB" }
    city                  { "Daresbury" }

    before :create do |account, evaluator|
      stub_request(:post, "http://keycloak.example.com/admin/realms/master/users").to_return_json(
        headers: {
          Location: "http://keycloak.example.com/admin/realms/master/users/#{evaluator.id}"
        }
      )
    end
  end
end
