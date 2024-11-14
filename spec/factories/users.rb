FactoryBot.define do
  factory :user, aliases: [ :participant, :host ] do
    email { Faker::Internet.email }
    password { "password123" }
    confirmed_at { Time.current } # pour simuler un utilisateur confirmé
    # city { association(:city) }
  end
end
