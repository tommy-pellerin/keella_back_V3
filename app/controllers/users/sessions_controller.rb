class Users::SessionsController < Devise::SessionsController
  # Logs de Débogage
  def create
    super do |resource|
      if resource.errors.any?
        # S'il y a des erreurs d'authentification
        Rails.logger.debug "Login failed for email: #{params[:user][:email]}"
        render json: { error: "email ou mot de passe invalide" }, status: :unauthorized and return
      else
        # Si la connexion est réussie
        Rails.logger.info("User signed in: #{resource.email}, ID: #{resource.id}")
        respond_with resource and return
      end
    end
  end

  def destroy
    Rails.logger.debug "Attempting to log out user..."
    if user_signed_in?
      Rails.logger.debug "User is signed in, proceeding to sign out."
      sign_out(current_user)
      log_out_success
    else
      Rails.logger.debug "User not signed in, cannot log out."
      log_out_failure
    end
  end

  private

  def respond_with(_resource, _opts = {})
    render json: {
      message: "You are logged in.",
      user: current_user
    }, status: :ok
  end

  def respond_to_on_destroy
    log_out_success && return if current_user

    log_out_failure
  end

  def log_out_success
    render json: { message: "You are logged out." }, status: :ok
  end

  def log_out_failure
    render json: { message: "Hmm nothing happened." }, status: :unauthorized
  end
end
