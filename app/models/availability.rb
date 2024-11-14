class Availability < ApplicationRecord
  # Relations
  belongs_to :workout
  # Un créneau peut avoir plusieurs réservations
  has_many :reservations
  # Un créneau peut avoir plusieurs participants via les réservations
  has_many :participants, through: :reservations, source: :participant

  # Validation pour la présence de la date de début et de l'heure de début
  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  # Validation pour le nombre maximal de participants : doit être supérieur à 0
  validates :max_participants, presence: true, numericality: { greater_than: 0 }

  # Validation pour l'heure de fin
  validate :end_time_after_start_time

  # Validation pour la réservation
  validates :is_booked, inclusion: { in: [ true, false ] }

  private

  # Validation pour vérifier que end_time est après start_time
  def end_time_after_start_time
    return unless date && start_time && end_time

    # puts "start_time: #{start_time}, end_time: #{end_time}" # Débogage
    if end_time <= start_time
      errors.add(:end_time, "doit être après l'heure de début")
    end
  end
end
