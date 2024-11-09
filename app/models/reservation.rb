class Reservation < ApplicationRecord
  # Callbacks
  before_create :set_total_price
  # Callback pour mettre à jour la date du changement de statut
  after_update :update_status_changed_at, if: :saved_change_to_status?

  # Relations
  belongs_to :user
  belongs_to :workout

  # Validations
  validates :user, presence: true
  validates :workout, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true

  # personalized method validations
  # validate :check_availability
  # validate :check_overlap

  private

  # Vérifie si l'utilisateur a déjà une réservation pour le même créneau
  # def check_overlap
  #   overlapping_reservation = Reservation.where(user_id: user.id, workout_id: workout.id)
  #                                         .where("start_date = ? AND start_time < ? AND end_time > ?", start_date, end_time, start_time)
  #                                         .or(Reservation.where(user_id: user.id, workout_id: workout.id)
  #                                         .where("start_date = ? AND start_time < ? AND end_time > ?", start_date, start_time, end_time))
  #                                         .exists?
  #   if overlapping_reservation
  #     errors.add(:base, "Vous avez déjà une réservation pour ce créneau horaire.")
  #   end
  # end

  # Vérifie si le nombre de places disponibles est suffisant pour la réservation
  def check_availability
    available_places = workout.max_participants - workout.reservations.where(status: [ "pending", "accepted" ]).sum(:quantity)
    errors.add(:quantity, "La séance de sport est complète") if available_places < 0
    errors.add(:quantity, "Il n'y a pas assez de places disponibles") if quantity > available_places
  end

  def set_relaunched_at
    self.relaunched_at = Time.current
  end

  def update_status_changed_at
    self.update_column(:status_changed_at, Time.current)
  end

  # Calcul du total de la réservation (exemple)
  def set_total_price
    self.total = workout.price_per_session * quantity if workout && quantity
  end

  # for information, the above line is deprecated and replaced => the order of the element in the array is very very important !
  # see here : https://sparkrails.com/rails-7/2024/02/13/rails-7-deprecated-enum-with-keywords-args.html
  enum :status, [ :pending, :accepted, :refused, :host_cancelled, :user_cancelled, :closed, :expired ]

  # Enum pour les raisons d'annulation
  enum :cancellation_reason, [
    :personal_reasons,
    :scheduling_conflict,
    :illness,
    :found_alternative,
    :financial_reasons,
    :other
  ]
end
