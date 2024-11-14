class Workout < ApplicationRecord
  # Relations
  belongs_to :city
  belongs_to :category
  belongs_to :host, class_name: "User"
  has_many :availabilities
  # On connecte workout à user (participant) en passant par availability puis reservation
  # Un workout peut avoir plusieurs réservations via les disponibilités,
  has_many :reservations, through: :availabilities
  # Un workout peut avoir plusieurs participants via les réservations
  has_many :participants, through: :reservations, source: :participant

  # Validations
  # Validation pour le titre : doit être présent et unique
  validates :title, presence: true, uniqueness: true, length: { minimum: 5, maximum: 100 }

  # Validation pour la description : doit être présente mais peut être vide
  validates :description, length: { minimum: 10, maximum: 1000 }, allow_blank: true

  # Validation pour les équipements : peut être vide
  validates :equipments, length: { maximum: 1000 }, allow_blank: true

  # Validation pour l'adresse, la ville
  validates :address, presence: true
  validates :city, presence: true
  # Validation pour la durée par session : doit être un nombre supérieur ou égale à 30 minutes,
  validates :duration_per_session, numericality: { greater_than_or_equal_to: 30 }
  # Validation pour le prix par session : doit être un nombre, et peut être 0 (gratuit)
  validates :price_per_session, numericality: { greater_than_or_equal_to: 0 }

  # Validation pour le nombre maximal de participants : doit être supérieur à 0
  validates :max_participants, presence: true, numericality: { greater_than: 0 }

  # Validation pour l'hôte : l'hôte doit exister dans la base de données
  validates :host, presence: true

  # Validation pour la catégorie : la catégorie doit exister dans la base de données
  validates :category, presence: true

  # Validation pour les booléens : doit être un booléen (par défaut à true)
  validates :is_indoor, inclusion: { in: [ true, false ] }
  validates :host_present, inclusion: { in: [ true, false ] }

  # Validation pour le statut : doit être un statut valide
  # validates :status, presence: true, inclusion: { in: [ "0", "1", "2", "3", "4" ] }

  # Validation des associations
  validates_associated :category, :host

  # Callback pour empêcher la suppression si des réservations sont présentes
  before_destroy :check_for_reservations

  private

  def check_for_reservations
    if reservations.any?
      errors.add(:base, "Cannot delete workout with active reservations")
      throw(:abort)  # Empêche la suppression
    end
  end

  enum :status, [ :pending, :validated, :published, :suspended, :closed ]
end
