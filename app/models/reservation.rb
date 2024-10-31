class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :workout

  # Validations
  validates :user, presence: true
  validates :workout, presence: true
  # validates :quantity, presence: true
  # validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
