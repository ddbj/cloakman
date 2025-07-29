FactoryBot.define do
  factory :user do
    sequence(:id)         { "john#{it}" }
    password              { 'P@ssw0rd' }
    password_confirmation { 'P@ssw0rd' }
    email                 { "#{id}@example.com" }
    first_name            { 'John' }
    last_name             { 'Doe' }
    organization          { 'Acme Corporation' }
    country               { 'US' }
    city                  { 'Anytown' }

    trait :admin do
      account_type_number { :ddbj }
    end
  end
end
