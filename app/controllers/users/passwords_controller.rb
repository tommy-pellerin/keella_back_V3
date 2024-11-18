class Users::PasswordsController < Devise::PasswordsController
  before_action :authenticate_user!, only: [ :update ]

  # Pour les utilisateurs non connectés : demander un email de réinitialisation
  def create
    self.resource = resource_class.send_reset_password_instructions(reset_password_params)

    if successfully_sent?(resource)
      render json: { message: "Email de réinitialisation envoyé." }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Pour les utilisateurs non connectés : soumettre un nouveau mot de passe avec un token
  def update
    # puts "### update password ###"
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?
      render json: { message: "Mot de passe mis à jour avec succes." }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Paramètres autorisés pour la demande de réinitialisation
  def reset_password_params
    params.require(:user).permit(:email)
  end

  def resource_params
    params.require(:user).permit(:reset_password_token, :password, :password_confirmation)
  end
end
