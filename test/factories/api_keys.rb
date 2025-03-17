FactoryBot.define do
  factory :api_key do
    sequence(:name) { "Key #{it}" }
  end
end
