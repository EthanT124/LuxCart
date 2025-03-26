# app/controllers/users/passwords_controller.rb
class Users::PasswordsController < ApplicationController
  # Ensure the user is authenticated before accessing any actions
  before_action :authenticate_user!

  # Render the form for editing the user's password
  def edit
    # Currently empty implementation (relies on the corresponding view)
  end

  # Update the user's password
  def update
    # Attempt to update the user's password with the provided parameters
    if current_user.update(password_params)
      # Redirect to the homepage with a success message if the update is successful
      redirect_to root_path, notice: 'Password successfully updated.'
    else
      # Render the edit form again if the update fails
      render :edit
    end
  end

  private

  # Strong parameters for updating the password
  def password_params
    # Permit only the password and password confirmation fields
    params.require(:user).permit(:password, :password_confirmation)
  end
end
