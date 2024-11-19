class Availability < ApplicationRecord
  # Callback pour empêcher la suppression si des réservations sont présentes
  before_destroy :check_for_reservations

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

  # personalized method validations
  validate :end_time_after_start_time



  # Calcule le nombre de places disponibles
  def available_slots
    max_participants - reservations.where(status: [ "pending", "accepted" ]).sum(:quantity)
  end

  # Vérifie si le créneau est complet
  def full?
    available_slots <= 0
  end

  private


  def check_for_reservations
    if reservations.any?
      errors.add(:base, "Cannot delete availability with active reservations")
      throw(:abort)  # Empêche la suppression
    end
  end

  # Validation pour vérifier que end_time est après start_time
  def end_time_after_start_time
    return unless date && start_time && end_time

    # puts "start_time: #{start_time}, end_time: #{end_time}" # Débogage
    if end_time <= start_time
      errors.add(:end_time, "doit être après l'heure de début")
    end
  end
end
