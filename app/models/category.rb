class Category < ApplicationRecord
  # Relations
  has_many :workouts

  # Validations
  validates :title, presence: true, uniqueness: true
end
