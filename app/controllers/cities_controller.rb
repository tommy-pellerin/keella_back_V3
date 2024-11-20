class CitiesController < ApplicationController
  before_action :authenticate_user!, except: %i[ index ]
  before_action :set_city, only: %i[ show update destroy ]
  before_action :authorize_admin!, only: %i[ show create update destroy ]

  # GET /cities
  def index
    Rails.logger.debug "Current user: #{current_user.inspect}" # Vérifie si un utilisateur est connecté
    @cities = City.all

    render json: @cities
  end

  # GET /cities/1
  def show
    render json: @city
  end

  # POST /cities
  def create
    # puts "#### create city"
    @city = City.new(city_params)
    # puts @city.inspect
    if @city.save
      # puts "#### create city success"
      render json: @city, status: :created, location: @city
    else
      # puts "#### create city failed"
      render json: @city.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cities/1
  def update
    if @city.update(city_params)
      render json: @city
    else
      render json: @city.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cities/1
  def destroy
    if @city.destroy
      render json: { message: "City deleted successfully." }, status: :ok
    else
      render json: { error: "Failed to delete city" }, status: :unprocessable_entity
    end
  end

  private

  def authorize_admin!
    render json: { error: "Vous n'êtes pas administrateur, vous ne pouvez acceder à cette page." }, status: :unauthorized unless current_user.is_admin?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_city
    @city = City.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def city_params
    params.require(:city).permit(
      :name,
      :zip_code
    )
  end
end
