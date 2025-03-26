class ApplicationController < ActionController::Base
  # Configure additional permitted parameters for Devise controllers
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Protect from forgery with an exception unless the request path matches OmniAuth routes
  protect_from_forgery with: :exception, unless: -> { request.path =~ /^\/auth\// }

  # Make helper methods available to views
  helper_method :require_admin, :current_user

  # Ensure the current user is an admin
  def require_admin
    unless current_user&.admin?
      # Redirect to the homepage with an alert if the user is not authorized
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end

  # Set the count of unread notifications for the current user
  def set_notifications_count
    if user_signed_in?
      # Count notifications with a status of false (unread)
      @notifications_count = Notification.where(user_id: current_user.id, status: false).count
    end
  end

  protected

  # Configure additional permitted parameters for Devise
  def configure_permitted_parameters
    # Permit additional parameters for user sign-up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation])
    # Permit additional parameters for account updates
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :password, :password_confirmation, :current_password])
  end

  # Define the path to redirect to after signing out
  def after_sign_out_path_for(resource_or_scope)
    root_path # Redirect to the homepage or any other path you want
  end
end
