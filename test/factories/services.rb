FactoryBot.define do
  factory :service do
    sequence(:username) { "serivce#{it}" }
  end
end
