class Users::PasswordsController < Devise::PasswordsController
  before_action :authenticate_user!

  def update
    # Cas 1 : Réinitialisation de mot de passe avec un token
    if params[:user][:reset_password_token].present?
      user = User.with_reset_password_token(params[:user][:reset_password_token])

      if user.nil?
        return render json: { error: "Token invalide ou expiré" }, status: :unauthorized
      end

      # Vérifie que le nouveau mot de passe et la confirmation correspondent
      if params[:user][:password] != params[:user][:password_confirmation]
        return render json: { error: "La confirmation du mot de passe ne correspond pas" }, status: :unprocessable_entity
      end

      # Tente de mettre à jour le mot de passe
      if user.reset_password(params[:user][:password], params[:user][:password_confirmation])
        render json: { message: "Mot de passe réinitialisé avec succès" }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end

    # Cas 2 : Changement de mot de passe pour un utilisateur authentifié
    else
      user_params = params.require(:user).permit(:current_password, :password, :password_confirmation)

      # Vérifie le mot de passe actuel
      if user_params[:current_password].blank? || !current_user.valid_password?(user_params[:current_password])
        return render json: { error: "Mot de passe actuel incorrect ou manquant" }, status: :unauthorized
      end

      # Vérifie que le nouveau mot de passe et la confirmation correspondent
      if user_params[:password].blank? || user_params[:password] != user_params[:password_confirmation]
        return render json: { error: "La confirmation du mot de passe ne correspond pas" }, status: :unprocessable_entity
      end

      # Tente de mettre à jour le mot de passe
      if current_user.update(password: user_params[:password])
        render json: { message: "Mot de passe mis à jour avec succès" }, status: :ok
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
