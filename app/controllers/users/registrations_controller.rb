# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  # Configure additional parameters for user sign-up
  before_action :configure_sign_up_params, only: [:create]

  protected

  # Permit additional parameters for user sign-up
  def configure_sign_up_params
    # Allow the `username` and `email` fields to be included during sign-up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email])
  end
end
