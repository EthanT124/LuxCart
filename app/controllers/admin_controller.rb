class AdminController < ApplicationController
  # Ensure only admins can access these actions
  before_action :require_admin
  # Set the item for edit, update, and destroy actions
  before_action :set_item, only: [:edit, :update, :destroy]
  # Include Pagy for pagination
  include Pagy::Backend
  # Skip CSRF verification for all actions
  skip_before_action :verify_authenticity_token

  # Render the admin dashboard
  def index
    # Initialize a new user object
    @user = User.new
  end

  # Display a list of all admins
  def admins
    # Fetch all users
    @users = User.all
  end

  # Display notifications for the admin
  def notifications
    # Fetch all users and notifications
    @users = User.all
    @notifications = Notification.all

    # Convert users and notifications to JSON for use in the view
    @users_json = @users.to_json
    @notifications_json = @notifications.to_json
  end

  # Render the form for creating a new user
  def new
    # Initialize a new user object
    @user = User.new
  end

  # Display a paginated list of items for CRUD operations
  def crud_items
    # Paginate the items (5 items per page)
    @pagy, @items = pagy(Item.all, items: 5)
  end

  # Create a new user
  def create
    # Initialize a new user with the provided parameters
    @user = User.new(user_params)
    if @user.save
      # Redirect to the admin users page with a success message
      redirect_to admin_users_path, notice: 'User was successfully created.'
    else
      # Render the new user form again if saving fails
      render :new
    end
  end

  # Render the form for editing an item
  def edit
  end

  # Update an existing item
  def update
    # Find the item by its ID
    @item = Item.find(params[:id])
    if @item.update(item_params)
      # Handle file attachments (images and videos)
      handle_attachments
      # Redirect to the manage items page with a success message
      redirect_to '/admin/manage_items', notice: 'Item was successfully updated.'
    else
      # Render the edit form again if updating fails
      render :edit
    end
  end

  # Delete an item
  def destroy
    # Destroy the item
    @item.destroy
    # Redirect to the manage items page with a success message
    redirect_to '/admin/manage_items', notice: 'Item was successfully deleted.'
  end

  # Delete a notification
  def destroy_notifications
    # Find the notification by its ID
    @notification = Notification.find(params[:id])

    if @notification
      # Destroy the notification if it exists
      @notification.destroy
      respond_to do |format|
        # Redirect to the admin notifications page with a success message
        format.html { redirect_to admin_notifications_path, notice: 'Notification was successfully deleted.' }
        # Return a no-content response for JSON requests
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        # Redirect to the admin notifications page with an error message if the notification is not found
        format.html { redirect_to admin_notifications_path, alert: 'Notification not found.' }
        # Return a not-found error for JSON requests
        format.json { render json: { error: 'Notification not found' }, status: :not_found }
      end
    end
  end

  private

  # Set the item for edit, update, and destroy actions
  def set_item
    @item = Item.find(params[:id])
  end

  # Strong parameters for creating or updating an item
  def item_params
    params.require(:item).permit(:title, :description, :cost, :sku, :quantity, :category, :weight, :discount, :published, images: [])
  end

  # Set the user for specific actions
  def set_user
    @user = User.find(params[:id])
  end

  # Strong parameters for creating or updating a user
  def user_params
    params.require(:user).permit(:username, :email, :admin)
  end

  # Handle file attachments for an item
  def handle_attachments
    # Attach images if provided
    if params[:item][:images].present?
      params[:item][:images].each do |image|
        @item.images.attach(image)
      end
    end

    # Attach a video if provided
    @item.video.attach(params[:item][:video]) if params[:item][:video].present?

    # Initialize the paths array
    @item.paths = []

    # Add paths for each attached image
    @item.images.each do |image|
      @item.paths << rails_blob_path(image, only_path: true)
    end

    # Add the path for the attached video
    @item.paths << rails_blob_path(@item.video, only_path: true) if @item.video.attached?

    # Save the item with updated paths
    @item.save
  end
end
