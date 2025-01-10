FactoryBot.define do
  factory :account do
    transient do
      sequence :id
    end

    username              { "alice" }
    password              { "P@ssw0rd" }
    password_confirmation { "P@ssw0rd" }
    first_name            { "Alice" }
    last_name             { "Liddell" }
    email                 { "alice@examle.com" }

    before :create do |account, evaluator|
      stub_request(:post, "http://keycloak.example.com/admin/realms/master/users").to_return_json(
        headers: {
          Location: "http://keycloak.example.com/admin/realms/master/users/#{evaluator.id}"
        }
      )
    end
  end
end
