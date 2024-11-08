FactoryBot.define do
  factory :category do
    title { Faker::Lorem.word }
    # Ajoute d'autres attributs ici si nécessaire
  end
end
