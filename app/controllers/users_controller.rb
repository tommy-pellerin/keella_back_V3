class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_and_authorize_user, only: [ :update, :destroy ]

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/:id
  def show
    # puts "##### current user is : #{current_user.id}"
    user = User.find(params[:id])

    # Si l'utilisateur est un admin ou le profil du current_user, on montre toutes les informations
    if current_user == user || current_user.is_admin?
      render json: user.as_json(methods: [ :avatar_url ])
    else
      public_user_info = user.slice(:first_name, :last_name, :city_id, :professional)
      render json: public_user_info
    end
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      render json: { user: @user.as_json(methods: [ :avatar_url ]) }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    if @user.destroy
      render json: { message: "User deleted successfully." }, status: :ok
    else
      render json: { error: "Failed to delete user." }, status: :unprocessable_entity
    end
  end

  private

  def set_and_authorize_user
    # puts "current_user: #{current_user.id}"
    # puts "Attempting to access user: #{params[:id]}"
    # Si l'utilisateur est admin, il peut accéder à n'importe quel utilisateur
    # Sinon, on restreint l'accès à son propre profil
    @user = User.find(params[:id])
    # puts "Authorized user: #{@user.id}"
    # puts @user.inspect
    # Si l'utilisateur actuel n'est pas admin et tente de modifier un autre utilisateur
    # ou s'il n'est pas autorisé à effectuer l'action, renvoyer une erreur 401
    if @user != current_user && !current_user.is_admin?
      render json: { error: "Vous n'êtes pas autorisé à effectuer cette action" }, status: :unauthorized
    end

    # On peut aussi bloquer explicitement la tentative de modifier certains champs sensibles (comme is_admin)
    # au cas où l'utilisateur essaie de forcer une modification via les paramètres.
    if params[:user]&.key?(:is_admin) && !current_user.is_admin?
      render json: { error: "Modification du statut admin non autorisée" }, status: :unauthorized
    end
  end

  def user_params
    # Liste des paramètres autorisés de base
    permitted_params = [ :first_name, :last_name, :birthday, :phone, :city_id, :professional, :avatar ]

    # Si l'utilisateur est admin, on ajoute des champs sensibles comme is_admin et id_verified
    permitted_params << [ :is_admin, :id_verified ] if current_user.is_admin?

    # Permet uniquement les paramètres autorisés
    params.require(:user).permit(*permitted_params)
  end
end
