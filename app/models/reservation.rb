class Reservation < ApplicationRecord
  # Callbacks
  before_create :set_total_price
  # Callback pour mettre à jour la date du changement de statut
  after_update :update_status_changed_at, if: :saved_change_to_status?

  # Relations
  # Une réservation appartient à un participant (user)
  belongs_to :participant, class_name: "User", foreign_key: "participant_id"
  # Une réservation appartient à un créneau (availability)
  belongs_to :availability
  # L'accès au workout via la réservation en passant par la disponibilité
  has_one :workout, through: :availability

  # Validations
  validates :participant, presence: true
  validates :availability, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true

  # personalized method validations
  validate :check_availability, on: :create
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
    if availability.present?  # Vérifie si availability est présent
      # Vérifie si la quantité demandée est supérieure aux places restantes
      if quantity.present? && quantity > availability.available_slots
        errors.add(:quantity, "Le créneau est complet ou il n'y a pas assez de places disponibles.")
      # Vérifie si le créneau est complet
      elsif availability.full?
        errors.add(:quantity, "Ce créneau est complet.")
      end
    else
      errors.add(:availability, "La disponibilité est requise.")
    end
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
