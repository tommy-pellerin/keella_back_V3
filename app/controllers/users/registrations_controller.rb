
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  # Cette méthode est utilisée pour autoriser les nouveaux paramètres
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :authenticate_user!, only: [ :update ]

  # PATCH /users pour changer email et/ou mot de passe lorsque user est connecté
  def update
    # Vérifier si l'email est le même
    if params[:user][:email].present? && current_user.email == params[:user][:email]
      render json: { errors: [ "L'email est identique à l'email actuel. Aucun changement n'a été effectué." ] }, status: :unprocessable_entity
      return
    end

    # Mise à jour de l'email et/ou du mot de passe
    if current_user.update_with_password(user_params)
      # Reste connecté après mise à jour
      bypass_sign_in(current_user) if params[:user][:password].present?
      render json: { message: "Email et mot de passe mis à jour avec succès." }, status: :ok
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
      message: "Inscription avec succes. Un email de confirmation a été envoyé.",
      user: current_user
    }, status: :ok
  end

  def register_failed
    render json: { message: "Une erreur est survenue lors de l'inscription, veuillez vérifier vos informations." }, status: :unprocessable_entity
  end

  def configure_sign_up_params
    # Permet d'ajouter les nouveaux attributs dans les paramètres Devise
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name,
      :last_name,
      :birthday,
      :phone,
      :professional,
      :city_id
    ])
  end

  def user_params
    params.require(:user).permit(:email, :current_password, :password, :password_confirmation)
  end
end
