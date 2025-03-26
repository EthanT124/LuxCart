class CartController < ApplicationController
  include Pagy::Backend

  # Showing the cart
  def show
    @items = []
    @items_fetch = Item.all
    # Fetch items based on average score greater than 3
    items_with_high_score = @items_fetch.where('average_score >= ?', 3.0)

    # Fetch items with discounts greater than 0.0
    items_with_discount = @items_fetch.where('discount > ?', 0.0)

    # Combine the results and ensure they are unique
    combined_items = (items_with_high_score + items_with_discount).uniq

    # Paginate the combined results
    @recommended_items = combined_items
    puts @recommended_items

    # Get the cart cookie
    cart = cookies[:cart]

    # Initialize @qty as an empty hash
    @qty = {}

    # If the cart cookie exists
    if cart
      # Parse the JSON string into a hash
      cart_hash = JSON.parse(cart)

      # Use a lowercase variable name for the array of IDs
      ids = cart_hash["ids"]

      # Initialize @qty with the quantities from the cart
      @qty = cart_hash["qty"] || {}

      # Keep track of the original amount before taxation
      @original = cart_hash["total"].round(2)

      # Get the taxable amount
      @tax = (@original * 0.11).round(2)

      # Calculate the total amount
      @total = (@original + @tax).round(2)

      # Fetch the items from the database
      @items = Item.find(ids)

      # Calculate the savings based on items with discounts
      @savings = @items.select { |item| item.discount > 0.0 }.sum { |item| item.cost * @qty[item.id.to_s].to_i * (item.discount / 100.0) }.round(2)
    end

    # Render the view
    render :show
  end
end
