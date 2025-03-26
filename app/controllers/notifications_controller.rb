class NotificationsController < ApplicationController
  # Skip CSRF verification for all actions
  skip_before_action :verify_authenticity_token
  # Protect from forgery by using a null session
  protect_from_forgery with: :null_session

  # Display a list of notifications (currently empty implementation)
  def index
  end

  # Show a specific notification
  def show
    # Find the notification by its ID
    @notification = Notification.find(params[:id])
  end

  # Render the form for creating a new notification
  def new
    # Initialize a new notification object
    @notification = Notification.new
  end

  # Create a new notification
  def create
    # Initialize a new notification with the provided parameters
    @notification = Notification.new(notification_params)
    if @notification.save
      # Redirect to the admin notifications page if saved successfully
      redirect_to '/admin/notifications', notice: 'Notification was successfully created.'
    else
      # Redirect to the signup page if saving fails
      redirect_to signup_path
    end
  end

  # Update an existing notification
  def update
    # Find the notification by its ID
    @notification = Notification.find(params[:id])
    if @notification.update(update_notification_params)
      # Redirect to the notifications page if updated successfully
      redirect_to notifications_path, notice: 'Notification was successfully updated.'
    else
      # Redirect to the notifications page with an error message if updating fails
      redirect_to notifications_path, alert: 'Failed to update notification.'
    end
  end

  # Update the status of a notification
  def update_status
    # Find the notification by its ID
    @notification = Notification.find(params[:id])
    # Mark the notification as read (status = true)
    @notification.status = true
    @notification.save
  end

  # Delete a notification
  def destroy
    # Find the notification by its ID
    @notification = Notification.find(params[:id])
    if @notification
      # Destroy the notification if it exists
      @notification.destroy
      respond_to do |format|
        # Redirect to the notifications page with a success message
        format.html { redirect_to notifications_path, notice: 'Notification was successfully deleted.' }
        # Return a no-content response for JSON requests
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        # Redirect to the notifications page with an error message if the notification is not found
        format.html { redirect_to notifications_path, alert: 'Notification not found.' }
        # Return a not-found error for JSON requests
        format.json { render json: { error: 'Notification not found' }, status: :not_found }
      end
    end
  end

  private

  # Strong parameters for creating a notification
  def notification_params
    params.require(:notification).permit(:subject, :notif, :created_at, :issuer, :user_id)
  end

  # Strong parameters for updating a notification
  def update_notification_params
    params.require(:notification).permit(:notification_ID, :subject, :notif, :created_at, :updated_at, :user_id)
  end
end
