class ApplicationController < ActionController::API
  # # Ce filtre s'assure que l'utilisateur est authentifié à l'exception des actions de connexion et d'inscription
  # before_action :authenticate_user!, except: [ :create, :new ]

  # private

  # # Override the authenticate_user! method
  # def authenticate_user!
  #   puts "#######"
  #   Rails.logger.debug "Authenticate user called."
  #   unless user_signed_in?
  #     render json: { error: "You need to be logged in" }, status: :unauthorized
  #   end
  # end
end
