class Workout < ApplicationRecord
  belongs_to :host, class_name: "User"
  belongs_to :category
  has_many :availabilities
  has_many :reservations, dependent: :destroy
  has_many :participants, through: :reservations, source: :user

  # Validations
  validates :host, presence: true
  # validates :title, presence: true, length: { minimum: 3, maximum: 50 }
end
