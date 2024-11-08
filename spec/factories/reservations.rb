FactoryBot.define do
  factory :reservation do
    association :user
    association :workout
    quantity { rand(0..5) }
    total { rand(0..100) }
    status { :pending }
  end
end
