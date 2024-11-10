FactoryBot.define do
  factory :reservation do
    participant { association(:participant) }
    availability { association(:availability) }
    quantity { rand(1..5) }
  end
end
