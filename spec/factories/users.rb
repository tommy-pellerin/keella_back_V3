FactoryBot.define do
  factory :user, aliases: [ :participant, :host ] do
    # Attributs de base
    email { Faker::Internet.email }
    password { "password123" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 65) } # Génère un âge valide (18+)
    phone { "0601020304" }
    id_verified { [ true, false ].sample }
    professional { [ true, false ].sample }
    is_admin { false }
    # Association avec la factory `City`
    city { association(:city) }
  end
end
