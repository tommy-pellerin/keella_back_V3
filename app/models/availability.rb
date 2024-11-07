class Availability < ApplicationRecord
  # Relations
  belongs_to :workout, dependent: :destroy

  # Validation pour la présence de la date de début et de l'heure de début
  validates :start_date, presence: true
  validates :start_time, presence: true
  validates :end_date, presence: true
  validates :duration, presence: true, numericality: { greater_than: 30 }  # La durée doit être supérieur à 30 minute

  # Validation pour l'heure de fin
  validate :end_date_after_start_time

  # Validation pour l'heure de début par rapport à la date de début
  validate :start_time_before_start_date

  # Validation pour la réservation
  validates :is_booked, inclusion: { in: [ true, false ] }

  # Validation des associations
  validates_associated :workout

  private

  # Validation pour vérifier que l'heure de fin est après l'heure de début
  def end_date_after_start_time
    if start_time && end_date && start_time >= end_date
      errors.add(:end_date, "doit être après l'heure de début")
    end
  end

  # Validation pour vérifier que l'heure de début est avant la date de début
  def start_time_before_start_date
    if start_date && start_time && start_date.to_time <= start_time
      errors.add(:start_time, "doit être avant la date de début")
    end
  end
end
