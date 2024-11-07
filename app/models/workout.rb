class Workout < ApplicationRecord
  # Relations
  belongs_to :host, class_name: "User"
  belongs_to :category
  has_many :availabilities
  has_many :reservations, dependent: :destroy
  has_many :participants, through: :reservations, source: :user

  # Validations
  # Validation pour le titre : doit être présent et unique
  validates :title, presence: true, uniqueness: true, length: { minimum: 5, maximum: 50 }

  # Validation pour la description : doit être présente mais peut être vide
  validates :description, length: { minimum: 10, maximum: 1000 }, allow_blank: true

  # Validation pour les équipements : peut être vide
  validates :equipments, length: { maximum: 1000 }, allow_blank: true

  # Validation pour l'adresse, la ville et le code postal
  validates :address, presence: true
  validates :city, presence: true
  validates :zip_code, presence: true, format: { with: /\A\d{5}\z/, message: "doit être un code postal valide" }

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
  validates :status, inclusion: { in: [ "pending", "active", "completed" ],
                                  message: "%{value} n'est pas un statut valide" }

  # Validation des associations
  validates_associated :category, :host
end
