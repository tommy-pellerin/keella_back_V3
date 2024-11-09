class AvailabilitiesController < ApplicationController
  before_action :set_availability, only: %i[ show update destroy ]

  # GET /availabilities
  def index
    @availabilities = Availability.all

    render json: @availabilities
  end

  # GET /availabilities/1
  def show
    render json: @availability
  end

  # POST /availabilities
  def create
    @availability = Availability.new(availability_params)

    if @availability.save
      render json: @availability, status: :created, location: @availability
    else
      render json: @availability.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /availabilities/1
  def update
    if @availability.update(availability_params)
      render json: @availability
    else
      render json: @availability.errors, status: :unprocessable_entity
    end
  end

  # DELETE /availabilities/1
  def destroy
    if @availability.destroy
      render json: { message: "Availability deleted successfully." }, status: :ok
    else
      render json: { error: "Failed to delete availability" }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_availability
      @availability = Availability.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def availability_params
      params.require(:availability).permit(:workout_id, :start_date, :start_time, :end_date, :duration, :is_booked)
    end
end
