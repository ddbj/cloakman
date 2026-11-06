FactoryBot.define do
  factory :api_key do
    sequence(:name) { "Factory key #{it}" }
  end
end
