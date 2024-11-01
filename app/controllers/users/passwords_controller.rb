class Users::PasswordsController < Devise::PasswordsController
  before_action :authenticate_user!

  def update_password
    user_params = params.require(:user).permit(:current_password, :new_password, :new_password_confirmation)

    # Vérification du mot de passe actuel
    if user_params[:current_password].blank? || !current_user.valid_password?(user_params[:current_password])
      return render json: { error: "Mot de passe actuel incorrect ou manquant" }, status: :unauthorized
    end

    # Vérification de la correspondance entre le nouveau mot de passe et la confirmation
    if user_params[:new_password] != user_params[:new_password_confirmation]
      return render json: { error: "La confirmation du mot de passe ne correspond pas" }, status: :unprocessable_entity
    end

    # Mise à jour du mot de passe
    if current_user.update(password: user_params[:new_password])
      render json: { message: "Mot de passe mis à jour avec succès" }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
