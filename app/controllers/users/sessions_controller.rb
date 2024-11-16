class Users::SessionsController < Devise::SessionsController
  # Surcharge la méthode create de Devise pour simplement faire du Débogage
  def create
    Rails.logger.debug "Attempting to log in user..."

    super do |resource|
      if resource.errors.any?
        # S'il y a des erreurs d'authentification
        Rails.logger.debug "Login failed for email: #{params[:user][:email]}"
        # render json: { error: "email ou mot de passe invalide" }, status: :unauthorized and return
      else
        # Si la connexion est réussie
        Rails.logger.info("User signed in: #{resource.email}, ID: #{resource.id}")
        respond_with resource and return
      end
    end
  end

  # Devise ne passe pas l'utilisateur (resource) à la méthode destroy, donc le paramètre resource dans votre méthode est inutile et ne recevra jamais l'utilisateur. Vous devez vous baser sur current_user pour vérifier si un utilisateur est connecté.
  # def destroy
  #   Rails.logger.debug "Attempting to log out user..."
  #   if current_user
  #     Rails.logger.info "User signed out: #{current_user.email}, ID: #{current_user.id}"
  #   else
  #     Rails.logger.debug "No user signed in, cannot log out."
  #   end
  #   super # Effectue l'action standard de Devise pour déconnecter l'utilisateur
  #     # l'appel à super ne doit pas être suivi d'autres actions
  # end

  private

  def respond_with(resource, _opts = {})
    render json: {
      message: "You are logged in.",
      user: current_user
    }, status: :ok
  end

  # Définir comment répondre après la déconnexion
  def respond_to_on_destroy
    # if request.headers["Authorization"].present?
    #   current_user = set_user
    # end

    if current_user # Si l'utilisateur est déconnecté correctement
      # puts "### logout success"
      log_out_success
    else
      # puts "### logout failed"
      log_out_failed
    end
  end

  def log_out_success
    render json: { message: "Déconnexion réussie." }, status: :ok
  end

  def log_out_failed
    render json: { message: "Aucun utilisateur n'est connecté." }, status: :unauthorized
  end

  # def get_user_from_token(token)
  #   jwt_payload = JWT.decode(token, Rails.application.credentials.devise[:jwt_secret_key]).first
  #   user_id = jwt_payload["sub"]
  #   User.find(user_id.to_s)
  # rescue JWT::DecodeError => e
  #   render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
  #   nil
  # end

  # def set_user
  #   @token = request.headers["Authorization"].split(" ").last
  #   get_user_from_token(@token)
  # end
end
