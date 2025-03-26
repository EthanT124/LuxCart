class ItemsController < ApplicationController
  # Make helper methods available to views
  helper_method :current_user, :logged_in?, :require_admin
  # Include Pagy for pagination
  include Pagy::Backend

  # Display a list of items
  def index
    if params[:search].present?
      # Search for items by title (case-insensitive)
      @pagy, @items = pagy(Item.where("LOWER(title) LIKE ?", "%#{params[:search].downcase}%"), items: 8)
    elsif params[:category].present? && params[:category] == "reset"
      # Reset the category filter and fetch all items
      @pagy, @items = pagy(Item.all, items: 8)
    elsif params[:category].present?
      # Filter items by category (case-insensitive)
      @pagy, @items = pagy(Item.where("LOWER(category) LIKE ?", "%#{params[:category].downcase}%"), items: 8)
    else
      # Fetch all items if no filters are applied
      @pagy, @items = pagy(Item.all, items: 8)
    end

    # Fetch unique categories for filtering
    @categories = Item.pluck(:category).uniq

    # Calculate total reviews and average rating for each item
    @items.each do |item|
      item.define_singleton_method(:total_reviews) do
        Review.where(item_id: item.id).count
      end

      item.define_singleton_method(:average_rating) do
        Review.where(item_id: item.id).average(:score).to_f.round(1)
      end
    end
  end

  # Display a specific item
  def show
    # Find the item by its ID
    @item = Item.find(params[:id])
    # Initialize a new review object for the item
    @review = Review.new
    # Fetch all reviews for the item
    @reviews = Review.where(item_id: @item.id)
    # Count the total number of reviews
    @reviews_count = @reviews.count
    # Calculate the average rating for the item
    @average_rating = @item.average_rating
    # Fetch the rating distribution for the item
    @rating_distributions = @item.rating_distributions

    # Paginate the reviews (5 reviews per page)
    @reviews = @reviews.limit(5).offset(params[:page].to_i * 5)

    # Check if the item is in the current user's wishlist
    if @current_user
      @in_wishlist = current_user.wishlist.include?(@item.id)
    else
      @in_wishlist = false
    end

    # Fetch all items for additional calculations
    @items = Item.all
    @items.each do |item|
      item.define_singleton_method(:total_reviews) do
        Review.where(item_id: item.id).count
      end

      item.define_singleton_method(:average_rating) do
        Review.where(item_id: item.id).average(:score).to_f.round(1)
      end
    end

    # Calculate the total reviews for the specific item
    @total_reviews = @item.total_reviews
    render :show
  end

  # Delete an item
  def destroy
    # Find the item by its ID
    @item = Item.find(params[:id])
    # Destroy the item
    @item.destroy

    # Redirect back with a success message
    redirect_back(fallback_location: items_path, notice: 'Item was successfully deleted.')
  rescue ActiveRecord::RecordNotFound
    # Handle the case where the item is not found
    redirect_back(fallback_location: items_path, alert: 'Item not found.')
  end

  # Render the form for creating a new item
  def new
    # Initialize a new item object
    @item = Item.new
  end

  # Create a new item
  def create
    # Initialize a new item with the provided parameters
    @item = Item.new(item_params)

    if @item.save
      # Handle file attachments (images and videos)
      handle_attachments
      # Redirect to the item's page with a success message
      redirect_to @item, notice: 'Item was successfully created.'
    else
      # Render the new item form again if saving fails
      render :new
    end
  end

  # Add an item to the user's wishlist
  def add_to_wishlist
    @user = current_user
    item_id = params[:id].to_i

    Rails.logger.debug "Adding item #{item_id} to wishlist for user #{@user.id}"

    if @user.wishlist.include?(item_id)
      # Log and return a message if the item is already in the wishlist
      Rails.logger.debug "Item #{item_id} is already in the wishlist"
      render json: { message: 'Item is already in the wishlist' }, status: :ok
    else
      # Add the item to the user's wishlist
      @user.wishlist << item_id

      if @user.save
        # Log and return a success message if the item is added successfully
        Rails.logger.debug "Item #{item_id} successfully added to wishlist"
        render json: { message: 'Item added to wishlist' }, status: :ok
      else
        # Log and return an error message if saving fails
        Rails.logger.debug "Failed to add item #{item_id} to wishlist: #{@user.errors.full_messages.join(', ')}"
        render json: { error: 'Failed to add item to wishlist', details: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  # Check if the user is logged in
  def logged_in?
    !!current_user
  end

  # Ensure the user is an admin
  def require_admin
    unless current_user&.admin?
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end

  private

  # Ensure the user is logged in
  def require_login
    unless current_user?
      flash[:alert] = "You must be logged in to access this page"
      redirect_to "/login"
    end
  end

  # Strong parameters for creating or updating an item
  def item_params
    params.require(:item).permit(:title, :cost, :description, :sku, :quantity, :category, :weight, :published, :discount, :rating, paths: [], images: [], video: [])
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
