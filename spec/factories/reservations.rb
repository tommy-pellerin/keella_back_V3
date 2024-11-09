FactoryBot.define do
  factory :reservation do
    association :user
    association :workout
    quantity { rand(1..5) }
    status { :pending }
  end
end
