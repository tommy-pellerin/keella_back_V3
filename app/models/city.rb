class City < ApplicationRecord
  # Relations
  has_many :users
  has_many :workouts

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :zip_code, presence: true, format: { with: /\A\d{5}\z/, message: "doit être un code postal valide" }
end
