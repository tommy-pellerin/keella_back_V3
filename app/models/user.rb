class User < ApplicationRecord
  belongs_to :city
  # Quand il est host
  has_many :hosted_workouts, foreign_key: "host_id", class_name: "Workout"
  # Quand il est participant
  has_many :reservations, foreign_key: "participant_id"
  # Un participant peut avoir plusieurs workouts via les réservations
  has_many :booked_workouts, through: :reservations, source: :workout

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable, :confirmable, :jwt_authenticatable,
        jwt_revocation_strategy: JwtDenylist

  # Validation de présence pour les champs obligatoires
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :birthday, presence: true

  # french phone number start with +33, 0033 or 0, following by 9 numbers that can be separate by space, dot or dash
  validates :phone, presence: true,
  format: {
    with: /\A(?:(?:\+|00)33[\s.-][1-9](?:[\s.-]?\d{2}){4}|0[1-9](?:[\s.-]?\d{2}){4}|0[1-9]\d{8})\z/,
    message: "please enter a valid French number (e.g., 06 01 02 03 04, +33 6 01 02 03 04, 0033 6 01 02 03 04)"
  }

  validates :city_id, presence: true
  # Validation de l'ID vérifié
  validates :id_verified, inclusion: { in: [ true, false ] }

  # Validation de l'état professionnel
  validates :professional, inclusion: { in: [ true, false ]  }

  # Validation du statut d'admin
  validates :is_admin, inclusion: { in: [ true, false ] }

  # Validation de l'âge minimum (exemple 18 ans)
  validate :minimum_age


  private

  # Validation personnalisée pour l'âge minimum de l'utilisateur (par exemple, 18 ans)
  def minimum_age
    if birthday.present? && birthday >= 18.years.ago
      errors.add(:birthday, "You must be at least 18 years old")
    end
  end

  def welcome_send
    UserMailer.welcome_email(self).deliver_now
  end

  # Callback après confirmation d'email
  def after_confirmation
    welcome_send
  end

  enum :status, [ :active, :suspended, :disabled ]
end
