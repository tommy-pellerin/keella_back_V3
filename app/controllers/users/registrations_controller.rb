
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: %i[update]
  respond_to :json

  # PATCH /users/update_email
  def update_email
    # Vérifie le mot de passe actuel
    if user_params[:current_password].blank? || !current_user.valid_password?(user_params[:current_password])
      return render json: { error: "Mot de passe actuel incorrect ou manquant" }, status: :unauthorized
    end

    # Tente la mise à jour de l'email
    if current_user.update(email: user_params[:new_email])
      render json: { message: "Email mis à jour avec succès" }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def respond_with(resource, _opts = {})
    register_success && return if resource.persisted?

    register_failed
  end

  def register_success
    render json: {
      message: "Signed up sucessfully.",
      user: current_user
    }, status: :ok
  end

  def register_failed
    render json: { message: "Something went wrong." }, status: :unprocessable_entity
  end

  def user_params
    params.require(:user).permit(:new_email, :current_password)
  end
end
