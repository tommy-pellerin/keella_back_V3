class User < ApplicationRecord
  # belongs_to :city
  # Quand il est host
  has_many :hosted_workouts, foreign_key: "host_id", class_name: "Workout"
  # Quand il est participant
  has_many :reservations, foreign_key: "participant_id"
  has_many :booked_workouts, through: :reservations, source: :workout

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable, :confirmable, :jwt_authenticatable,
        jwt_revocation_strategy: JwtDenylist

  private

  def welcome_send
    UserMailer.welcome_email(self).deliver_now
  end

  # Callback après confirmation d'email
  def after_confirmation
    welcome_send
  end
end
