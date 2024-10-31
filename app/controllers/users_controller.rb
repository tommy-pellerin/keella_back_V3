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
      message: "If you see this, you're in!",
      user: user
    }
  end

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
    jwt_payload = JWT.decode(request.headers["Authorization"].split(" ")[1],
                            Rails.application.credentials.devise[:jwt_secret_key]).first
    user_id = jwt_payload["sub"]
    User.find(user_id.to_s)
  end
end
