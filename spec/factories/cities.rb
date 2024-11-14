FactoryBot.define do
  factory :city do
    name { Faker::Address.city  }
    zip_code { 75000 }
  end
end
