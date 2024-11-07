class Category < ApplicationRecord
  # Relations
  has_many :workouts

  # Validations
  validates :title, presence: true
end
