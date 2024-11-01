class ApplicationController < ActionController::API
    # Ce filtre avant action s'assure que l'utilisateur est authentifié
    before_action :authenticate_user!

    private

    # Override the authenticate_user! method
    def authenticate_user!
      unless user_signed_in?
        render json: { error: "You need to be logged in" }, status: :unauthorized
      end
    end
end
