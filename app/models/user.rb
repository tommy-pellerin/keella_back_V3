class User < ApplicationRecord
  before_destroy :detach_workouts

  # Quand il est host
  has_many :hosted_workouts, foreign_key: "host_id", class_name: "Workout", dependent: :destroy
  # Quand il est participant
  has_many :reservations, dependent: :destroy
  has_many :booked_workouts, through: :reservations, source: :workout, dependent: :destroy

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable, :confirmable, :jwt_authenticatable,
        jwt_revocation_strategy: JwtDenylist

  private

  def detach_workouts
    self.hosted_workouts.update_all(host_id: nil)  # Ou assignez une valeur par défaut ou un autre hôte.

    # Annuler toutes les réservations où l'utilisateur est un hôte
    self.reservations.each do |reservation|
      reservation.update(status: :host_cancelled)
    end
  end

  def welcome_send
    UserMailer.welcome_email(self).deliver_now
  end

  # Callback après confirmation d'email
  def after_confirmation
    welcome_send
  end
end
