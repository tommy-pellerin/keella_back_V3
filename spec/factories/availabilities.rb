FactoryBot.define do
  factory :availability do
    date { Date.today }
    start_time { Time.now }
    end_time { Time.now + 1.hour }
    max_participants { rand(1..50) }
    is_booked { false }
    workout { association(:workout) }
  end
end
