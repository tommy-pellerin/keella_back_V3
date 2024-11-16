FactoryBot.define do
  factory :reservation do
    participant { association(:participant) }
    availability { association(:availability) }
    workout { association :workout }
    quantity { rand(1..5) }
  end
end
