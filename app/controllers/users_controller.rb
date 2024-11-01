class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/:id
  def show
    user = get_user_from_token
    render json: {
      message: "User profile",
      user: user
    }
  end

  # PATCH/PUT /users/:id
  # def update
  #   user_params = params.require(:user).permit(:name, :other_field) # autres champs autorisés

  #   # Tente la mise à jour des informations
  #   if current_user.update(user_params)
  #     render json: { message: 'Informations utilisateur mises à jour avec succès' }, status: :ok
  #   else
  #     render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
  #   end
  # end

  # DELETE /users/:id
  def destroy
    user = get_user_from_token
    if user == current_user
      if user.destroy
        render json: { message: "User deleted successfully." }, status: :ok
      else
        render json: { error: "Failed to delete user." }, status: :unprocessable_entity
      end
    else
      render json: { error: "Vous n'êtes pas autorisé à effectuer cette action" }, status: :unauthorized
    end
  end

  private

  def get_user_from_token
    token = request.headers["Authorization"].split(" ")[1]
    jwt_payload = JWT.decode(token, Rails.application.credentials.devise[:jwt_secret_key]).first
    user_id = jwt_payload["sub"]
    User.find(user_id.to_s)
  rescue JWT::DecodeError => e
    render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
    nil
  end
end
