FactoryBot.define do
  factory :user do
    username              { "alice" }
    password              { "P@ssw0rd" }
    password_confirmation { "P@ssw0rd" }
    email                 { "alice@example.com" }
    first_name            { "Alice" }
    last_name             { "Liddell" }
    organization          { "Wonderland" }
    country               { "GB" }
    city                  { "Daresbury" }
  end
end
