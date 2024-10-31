class Category < ApplicationRecord
  has_many :workouts
  # Validations
  validates :name, presence: true
end
