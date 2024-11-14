class CitiesController < ApplicationController
  before_action :set_city, only: %i[ show update destroy ]
  before_action :authenticate_user!
  # GET /cities
  def index
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
