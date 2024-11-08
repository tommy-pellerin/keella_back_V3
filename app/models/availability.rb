class Availability < ApplicationRecord
  # Relations
  belongs_to :workout, dependent: :destroy

  # Validation pour la présence de la date de début et de l'heure de début
  validates :start_date, presence: true
  validates :start_time, presence: true
  validates :end_date, presence: true
  validates :duration, presence: true, numericality: { greater_than: 30 }  # La durée doit être supérieur à 30 minute

  # Validation pour l'heure de fin
  validate :end_date_after_start_date_and_time

  # Validation pour la réservation
  validates :is_booked, inclusion: { in: [ true, false ] }

  # Validation des associations
  validates_associated :workout

  private

  # Validation pour vérifier que end_date est après start_date et start_time
  def end_date_after_start_date_and_time
    if start_date && start_time && end_date
      start_datetime = start_date.to_datetime.change({ hour: start_time.hour, min: start_time.min })
      if end_date <= start_datetime
        errors.add(:end_date, "doit être après la date et l'heure de début")
      end
    end
  end
end
