class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: %i[ show update destroy ]
  before_action :authorize_user!, only: %i[ show update destroy ]

  # GET /reservations
  def index
    @reservations = Reservation.all

    render json: @reservations
  end

  # GET /reservations/1
  def show
    render json: @reservation
  end

  # POST /reservations
  def create
    @reservation = current_user.reservations.new(reservation_params)

    if @reservation.save
      render json: @reservation, status: :created, location: @reservation
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reservations/1
  def update
    # Autoriser uniquement la mise à jour du statut
    if @reservation.update(status: reservation_params[:status])
      render json: @reservation, status: :ok
    else
      render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /reservations/1
  def destroy
    if @reservation.destroy
      render json: { message: "Workout deleted successfully." }, status: :ok
    else
      render json: { error: "Failed to delete reservation" }, status: :unprocessable_entity
    end
  end

  private

  def authorize_user!
    # Soit le current user est participant (possede une réservation) soit il est hote du workout
    unless @reservation.participant == current_user || @reservation.workout.host == current_user
      render json: { error: "Vous n'êtes pas autorisé à effectuer cette action" }, status: :unauthorized
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def reservation_params
    params.require(:reservation).permit(:availability_id, :quantity, :status)
  end
end
