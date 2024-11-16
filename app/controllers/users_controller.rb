class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show update destroy]
  before_action :authorize_user, only: %i[update destroy]

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/:id
  def show
    render json: @user
  end

  # PATCH/PUT /users/:id
  def update
    if current_user.update(user_params)
      render json: { user: current_user }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    if user.destroy
      render json: { message: "User deleted successfully." }, status: :ok
    else
      render json: { error: "Failed to delete user." }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    # Si l'utilisateur actuel est un admin, on le laisse mettre à jour n'importe quel utilisateur
    # Sinon, on vérifie qu'il essaie de mettre à jour son propre profil
    @user = User.find(params[:id])
    if @user != current_user && !current_user.is_admin?
      render json: { error: "Vous n'êtes pas autorisé à effectuer cette action" }, status: :unauthorized
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :phone_number, :id_verified, :professional, :is_admin, :city_id)
  end
end
