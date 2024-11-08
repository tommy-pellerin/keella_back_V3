FactoryBot.define do
  factory :availability do
    start_date { Date.today }
    start_time { Time.now }
    end_date { Time.now + 1.hour }
    duration { 60 } # durée en minutes
    is_booked { false }
    association :workout
  end
end
