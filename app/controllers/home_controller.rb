class HomeController < ApplicationController
  # Include Pagy for pagination
  include Pagy::Backend

  # Render the contact page
  def contact
    # Currently empty implementation
  end

  # Render the homepage
  def index
    # Fetch all items from the database
    @Items = Item.all

    # Filter items with an average rating of 3 or higher
    review_items = @Items.where("average_rating >= 3")
    # Debugging output for testing purposes
    puts "this is just a test"
    puts '========================='

    # Paginate the review items (4 items per page)
    @pagy, @review_items = pagy(review_items, items: 4)

    # Filter items with a discount greater than 0
    discount_items = @Items.where("discount > 0")
    # Paginate the discount items (4 items per page)
    @pagy, @discount_items = pagy(discount_items, items: 4)
  end

  # Render the privacy policy page
  def privacy_policy
  end

  # Render the terms of service page
  def terms_of_service
  end
end
