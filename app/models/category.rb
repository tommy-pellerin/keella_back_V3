class Category < ApplicationRecord
  has_many :workouts
  # Validations
  validates :title, presence: true
end
