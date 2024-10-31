class ApplicationController < ActionController::API
    # Override the authenticate_user! method
    def authenticate_user!
      unless user_signed_in?
        render json: { error: "You need to be logged in" }, status: :unauthorized
      end
    end
end
