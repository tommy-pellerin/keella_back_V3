
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :authenticate_user!, only: %i[update]

  # PATCH /users
  def update
    # Vérifie le mot de passe actuel
    if user_params[:current_password].blank? || !current_user.valid_password?(user_params[:current_password])
      return render json: { error: "Mot de passe actuel incorrect ou manquant" }, status: :unauthorized
    end

    # Tente la mise à jour de l'email
    if current_user.update(email: user_params[:new_email])
      render json: { message: "Nous avons pris en compte la demande de mettre à jour votre email, vous allez recevoir un email de demande de confirmation" }, status: :ok
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
