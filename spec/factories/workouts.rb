FactoryBot.define do
  factory :workout do
    sequence(:title) { |n| "Workout Title #{n}" }
    description { Faker::Lorem.sentence(word_count: 20) }
    equipments { Faker::Lorem.sentence(word_count: 20) }
    address { Faker::Address.street_address }
    city { association(:city) } # Associe une ville
    price_per_session { rand(0..50) }
    duration_per_session { 60 } # en minutes
    max_participants { rand(1..50) }
    host { association(:user) }            # Associe un utilisateur comme hôte
    category { association(:category) }    # Associe une catégorie à ce workout
    is_indoor { [ true, false ].sample }
    host_present { [ true, false ].sample }
  end
end
