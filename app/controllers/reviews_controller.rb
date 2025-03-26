# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
  # Ensure the user is logged in before allowing certain actions
  before_action :require_login, only: [:create, :destroy]
  # Ensure the correct user is performing update or destroy actions
  before_action :require_correct_user, only: [:update, :destroy]
  # Set the review object for edit and update actions
  before_action :set_review, only: [:edit, :update]

  # Include Pagy for pagination
  include Pagy::Backend

  # Create a new review
  def create
    @review = Review.new(review_params)
    # Set the current date and time for the review
    @review.date = Time.current

    # Handle image uploads if images are provided
    if params[:review][:images].present?
      params[:review][:images].each do |image|
        @review.images.attach(image)
      end
    end

    # Save the review and update the item's rating
    if @review.save
      update_item_rating(@review.item_id)
      redirect_to item_path(@review.item_id), notice: 'Review created successfully.'
    else
      redirect_to item_path(@review.item_id), alert: 'Error creating review.'
    end
  end

  # Show all reviews for a specific user
  def show
    # Find the user by ID
    @user = User.find(params[:id])
    # Fetch all reviews for the user
    @reviews = Review.where(user_id: @user.id)
    # Paginate the reviews
    @pagy, @reviews = pagy(@reviews, items: 10)
  end

  # Edit a review
  def edit
    # Find the review by ID
    @review = Review.find(params[:id])
  end

  # Increment the "yes" count for a review
  def yes
    @review = Review.find(params[:id])
    @review.increment!(:yes) # Increment the "yes" count
    @review.save
  end

  # Increment the "no" count for a review
  def no
    @review = Review.find(params[:id])
    @review.increment!(:no) # Increment the "no" count
    @review.save
  end

  # Update an existing review
  def update
    puts "=============================================="
    puts "STARTING PUT REQUEST FOR REVIEW OF " + params[:id]
    @review = Review.find(params[:id])

    # Update the review with the provided parameters
    if @review.update(review_user_edit_params)
      puts "Review updated"
      puts "=============================================="
      puts @review.title
      puts "=============================================="
      puts @review.id

      # Handle image attachments if provided
      handle_attachments unless params[:review][:images].nil?
      # Update the item's rating after the review is updated
      update_item_rating(@review.item_id)
      redirect_to user_path(@review.user_id), notice: 'Review was successfully updated.'
    else
      puts "Review update failed"
      puts "=============================================="
      puts @review.errors.full_messages
      render :edit
    end
  end

  # Delete a review
  def destroy
    @review = Review.find(params[:id])
    item_id = @review.item_id
    # Destroy the review and update the item's rating
    @review.destroy
    update_item_rating(item_id)

    redirect_back(fallback_location: user_path(@review.user_id), notice: 'Review was successfully deleted.')
  rescue ActiveRecord::RecordNotFound
    # Handle the case where the review is not found
    redirect_back(fallback_location: user_path(@review.user_id), alert: 'Review not found.')
  end

  private

  # Strong parameters for editing a review
  def review_user_edit_params
    params.require(:review).permit(:title, :score, :description, images: [])
  end

  # Set the review object for edit and update actions
  def set_review
    @review = Review.find(params[:id])
  end

  # Strong parameters for creating a review
  def review_params
    params.require(:review).permit(:username, :user_id, :title, :score, :description, :item_id, :created_at, images: [])
  end

  # Handle image attachments for a review
  def handle_attachments
    if params[:review][:images].present?
      @review.images.attach(params[:review][:images])
    end

    @review.save
  end

  # Update the average rating for an item based on its reviews
  def update_item_rating(item_id)
    item = Item.find(item_id)
    reviews = Review.where(item_id: item_id)
    # Calculate the average rating and round to 1 decimal place
    average_rating = reviews.average(:score).to_f.round(1)

    # Update the item's average rating
    item.update(average_rating: average_rating)
  end

  # Ensure the user is logged in
  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page"
      redirect_to "/users/sign_in"
    end
  end

  # Ensure the correct user is performing the action
  def require_correct_user
    if action_name == 'show'
      @user = User.find(params[:id])
      unless current_user == @user
        puts "User not authorized"
        redirect_to(root_url, alert: "You are not authorized to perform this action.")
      else
        puts "User authorized"
      end
    else
      @review = Review.find(params[:id])
      @user = User.find(@review.user_id)
      puts "=============================================="
      puts "Checking user authorization"
      puts "Current user ID: #{current_user.id}"
      puts "Review user ID: #{@user.id}"
      unless current_user == @user
        puts "User not authorized"
        redirect_to(root_url, alert: "You are not authorized to perform this action.")
      else
        puts "User authorized"
      end
    end
  end

  # Check if the user is logged in
  def logged_in?
    !!current_user
  end
end
