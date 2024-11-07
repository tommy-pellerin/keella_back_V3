class Reservation < ApplicationRecord
  # Relations
  belongs_to :user
  belongs_to :workout

  # Validations
  validates :user, presence: true
  validates :workout, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  # Callbacks
  before_create :set_total_price
  # Callback pour mettre à jour la date du changement de statut
  after_update :update_status_changed_at, if: :saved_change_to_status?


  private

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
