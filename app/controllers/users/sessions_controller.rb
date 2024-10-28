class Users::SessionsController < Devise::SessionsController
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
