# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Handle Google OAuth2 callback
  def google_oauth2
    # Log the Omniauth state and session state for debugging
    Rails.logger.info("Omniauth state: #{request.env['omniauth.params']['state']}")
    Rails.logger.info("Session state: #{session['omniauth.state']}")

    # Find or create a user from the Omniauth authentication hash
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      # Sign in the user and redirect to the appropriate page
      sign_in_and_redirect @user, event: :authentication
      # Set a flash message indicating successful authentication
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      # Store the Omniauth data in the session (excluding extra data) for later use
      session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
      # Redirect to the registration page with error messages
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  # Handle GitHub OAuth callback
  def github
    # Find or create a user from the Omniauth authentication hash
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      # Sign in the user and redirect to the appropriate page
      sign_in_and_redirect @user, event: :authentication
      # Set a flash message indicating successful authentication
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
    else
      # Store the Omniauth data in the session for later use
      session["devise.github_data"] = request.env["omniauth.auth"]
      # Log the error messages for debugging
      puts @user.errors.full_messages
      puts "The error is here"
      # Redirect to the sign-in page with error messages
      redirect_to '/users/sign_in', alert: @user.errors.full_messages.join("\n")
    end
  end

  # Handle Facebook OAuth callback
  def facebook
    # Find or create a user from the Omniauth authentication hash
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      # Sign in the user and redirect to the appropriate page
      sign_in_and_redirect @user, event: :authentication
      # Set a flash message indicating successful authentication
      set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
    else
      # Store the Omniauth data in the session (excluding extra data) for later use
      session['devise.facebook_data'] = request.env['omniauth.auth'].except(:extra)
      # Redirect to the registration page with error messages
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  # Handle authentication failure
  def failure
    # Redirect to the homepage
    redirect_to root_path
  end
end
