FactoryBot.define do
  factory :category do
    sequence(:title) { |n| "#{n}. #{Faker::Lorem.word }" }
    # Ajoute d'autres attributs ici si nécessaire
  end
end
