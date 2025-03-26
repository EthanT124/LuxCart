class SessionsController < ApplicationController
  # Handle user login via OmniAuth
  def create
    # Find or create a user from the OmniAuth authentication hash
    user = User.from_omniauth(request.env['omniauth.auth'])
    # Store the user's ID in the session to keep them logged in
    session[:user_id] = user.id
    # Redirect to the homepage with a success message
    redirect_to root_path, notice: 'Signed in!'
  end

  # Handle user logout
  def destroy
    # Clear the user's session to log them out
    session[:user_id] = nil
    # Redirect to the homepage with a success message
    redirect_to root_path, notice: 'Signed out!'
  end
end
