FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    confirmed_at { Time.current } # pour simuler un utilisateur confirmé
    # Ajoute d'autres attributs ici si nécessaire
  end
end
