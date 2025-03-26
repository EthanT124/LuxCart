class UsersController < ApplicationController
  # Make it so that only logged-in users can access the account page
  before_action :authenticate_user!, only: [:account, :update_shipping_info, :show, :show_wishlist, :update_shipping, :update_personal, :link_account, :unlink_account, :update_email, :update_password, :update_username]

  # Use the pagy gem for pagination
  include Pagy::Backend

  # Make the logged_in? method available to the views
  helper_method :logged_in?

  # Define the account page
  def account
    # Get the current user
    @user = User.find_by(id: params[:id])
    # Get the user's notifications
    @notifications = Notification.where(user_id: @user.id)
  end

  # Define the new user page
  def new
    # Initialize a new user object
    @user = User.new
  end

  # Handle user creation
  def create
    @user = User.new(user_params)
    if @user.save
      # Redirect to the user's profile page if saved successfully
      redirect_to @user
    else
      # Render the new user form again if saving fails
      render :new
    end
  end

  # Update the user's email address
  def update_email
    if current_user.valid_password?(params[:current_password])
      if params[:new_email] == params[:confirm_email]
        # Update the email if the new email matches the confirmation
        current_user.update(email: params[:new_email])
        redirect_to account_path(current_user), notice: "Email updated successfully"
      else
        # Alert if the new email and confirmation do not match
        redirect_to account_path(current_user), alert: "New email and confirmation do not match"
      end
    else
      # Alert if the current password is incorrect
      redirect_to account_path(current_user), alert: "Current password is incorrect"
    end
  end

  # Update the user's password
  def update_password
    if current_user.valid_password?(params[:current_password])
      if params[:new_password] == params[:confirm_password]
        # Update the password and re-sign in the user
        current_user.update(password: params[:new_password])
        bypass_sign_in(current_user) # To avoid being signed out after password change
        redirect_to account_path(current_user), notice: "Password updated successfully"
      else
        # Alert if the new password and confirmation do not match
        redirect_to account_path(current_user), alert: "New password and confirmation do not match"
      end
    else
      # Alert if the current password is incorrect
      redirect_to account_path(current_user), alert: "Current password is incorrect"
    end
  end

  # Update the user's username
  def update_username
    if current_user.valid_password?(params[:current_password])
      if current_user.update(username: params[:new_username])
        # Notify if the username is updated successfully
        redirect_to account_path(current_user), notice: "Username updated successfully"
      else
        # Alert if the username update fails
        redirect_to account_path(current_user), alert: "Failed to update username"
      end
    else
      # Alert if the current password is incorrect
      redirect_to account_path(current_user), alert: "Current password is incorrect"
    end
  end

  # Link a third-party account to the user
  def link_account
    auth = request.env["omniauth.auth"]
    # Update the user's provider and UID with the third-party account details
    current_user.update(provider: auth.provider, uid: auth.uid)
    redirect_to account_path(current_user), notice: "Account linked successfully"
  end

  # Unlink a third-party account from the user
  def unlink_account
    provider = params[:provider]
    if current_user.provider == provider
      # Remove the provider and UID if they match
      current_user.update(provider: nil, uid: nil)
      redirect_to account_path(current_user), notice: "Account unlinked successfully"
    else
      # Alert if no linked account is found for the provider
      redirect_to account_path(current_user), alert: "No linked account found for #{provider}"
    end
  end

  # Render the update shipping info page
  def update_shipping_info
    @user = User.find(params[:id])
    render :update_shipping_info
  end

  # Show the user's profile and notifications
  def show
    @user = User.find_by(id: params[:id])
    if @user.nil?
      # Redirect to the homepage if the user is not found
      redirect_to root_path, alert: 'User not found'
    else
      # Fetch current and past notifications for the user
      @current_notifications = Notification.where(user_id: @user.id)
      @past_notifications = Notification.where(user_id: @user.id, status: true)
      @pagy, @past_notifications = pagy(@past_notifications, items: 5)
      @Order_Total = Order.where(user_id: @user.id).count
      @unread_notifications = Notification.where(user_id: @user.id, status: false)
      @notification_count = @unread_notifications.count
    end
  end

  # Show the user's wishlist
  def show_wishlist
    @user = User.find_by(id: params[:id])
    @wishlist_count = @user.wishlist.count
    @wishlist = Item.where(id: @user.wishlist)
    @pagy, @wishlist = pagy(@wishlist, items: 5)

    # Add methods to calculate total reviews and average rating for each item
    @wishlist.each do |item|
      item.define_singleton_method(:total_reviews) do
        Review.where(item_id: item.id).count
      end

      item.define_singleton_method(:average_rating) do
        Review.where(item_id: item.id).average(:score).to_f.round(1)
      end
    end

    # Calculate the average rating and total reviews for the wishlist
    @average_rating = @wishlist.map(&:average_rating).sum / @wishlist.size.to_f
    @total_reviews = @wishlist.map(&:total_reviews).sum
  end

  # Remove an item from the user's wishlist
  def remove_from_wishlist
    @user = current_user
    item_id = params[:id].to_i

    if @user.wishlist.include?(item_id)
      # Remove the item from the wishlist and save the user
      @user.wishlist.delete(item_id)
      if @user.save
        render json: { message: 'Item removed from wishlist!' }, status: :ok
      else
        render json: { error: 'Failed to save user.' }, status: :unprocessable_entity
      end
    else
      # Return an error if the item is not found in the wishlist
      render json: { error: 'Item not found in wishlist.' }, status: :not_found
    end
  end

  # Update the user's shipping information
  def update_shipping
    @user = User.find(params[:id])
    if @user.update(user_ship_params)
      # Return the updated user as JSON if successful
      render json: @user, status: :ok
    else
      # Return errors if the update fails
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Update the user's personal information
  def update_personal
    @user = User.find(params[:id])
    if @user.update(personal_params)
      # Return the updated user as JSON if successful
      render json: @user, status: :ok
    else
      # Return errors if the update fails
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  # Check if the user is logged in
  def logged_in?
    !!current_user
  end

  # Strong parameters for shipping details
  def user_ship_params
    params.require(:user).permit(shipping_details: [:address, :billing, :city, :province, :postal, :country])
  end

  # Strong parameters for personal information
  def personal_params
    params.require(:user).permit(:first_name, :last_name, :phone)
  end

  # Strong parameters for user creation and updates
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :reset_password_token)
  end
end
