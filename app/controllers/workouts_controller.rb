class WorkoutsController < ApplicationController
  before_action :authenticate_user!, except: %i[ index show ]
  before_action :set_workout, only: %i[ show update destroy ]
  before_action :authorize_user!, only: %i[update destroy]

  # GET /workouts
  def index
    @workouts = Workout.all

    render json: @workouts
  end

  # GET /workouts/1
  def show
    render json: @workout
  end

  # POST /workouts
  def create
    @workout = Workout.new(workout_params.merge(host: current_user))
    if @workout.save
      render json: @workout, status: :created, location: @workout
    else
      render json: @workout.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /workouts/1
  def update
    if @workout.update(workout_params)
      render json: @workout
    else
      render json: @workout.errors, status: :unprocessable_entity
    end
  end

  # DELETE /workouts/1
  def destroy
    if @workout.destroy
      render json: { message: "Workout deleted successfully." }, status: :ok
    else
      render json: { error: "Failed to delete workout" }, status: :unprocessable_entity
    end
  end

  private

  def authorize_user!
    unless @workout.host == current_user
      render json: { error: "Vous n'êtes pas autorisé à faire cette action" }, status: :unauthorized
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_workout
    @workout = Workout.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def workout_params
    params.require(:workout).permit(
      :title,               # Le titre du workout
      :description,         # La description du workout
      :equipments,          # Les équipements nécessaires
      :address,             # L'adresse du workout
      :city_id,                # La ville où se déroule le workout
      :zip_code,            # Le code postal
      :price_per_session,   # Le prix par session
      :max_participants,    # Le nombre maximal de participants
      :category_id,         # L'id de la catégorie du workout
      :is_indoor,           # Boolean pour savoir si c'est en intérieur
      :host_present,        # Boolean pour savoir si l'hôte est présent
      :status               # Le statut du workout (par exemple "actif", "inactif")
    )
  end
end
