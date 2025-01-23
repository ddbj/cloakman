FactoryBot.define do
  factory :account do
    username              { "alice" }
    password              { "P@ssw0rd" }
    password_confirmation { "P@ssw0rd" }
    email                 { "alice@examle.com" }
    first_name            { "Alice" }
    last_name             { "Liddell" }
    organization          { "Wonderland" }
    country               { "GB" }
    city                  { "Daresbury" }
  end
end
