FactoryBot.define do
  factory :reader do
    sequence(:username) { "serivce#{it}" }
  end
end
