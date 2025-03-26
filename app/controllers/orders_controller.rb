class OrdersController < ApplicationController
  # Make helper methods available to views
  helper_method :current_user, :logged_in?, :require_admin

  # Skip CSRF verification for the create action
  skip_before_action :verify_authenticity_token, only: [:create]

  # Include Pagy for pagination
  include Pagy::Backend

  # Ensure the user is authenticated before accessing the checkout action
  before_action :authenticate_user!, only: [:checkout]

  # Display the checkout page
  def checkout
    @user = current_user
    # Get the cart cookie
    cart = cookies[:cart]

    # If the cart cookie exists
    if cart
      # Parse the JSON string into a hash
      cart_hash = JSON.parse(cart)

      # Extract the array of item IDs
      ids = cart_hash["ids"]

      # Keep track of the original amount before taxation
      @original = cart_hash["total"].round(2)

      # Calculate and round the tax
      @tax = (0.11 * @original).round(2)

      # Calculate and round the total amount
      @total = (@tax + @original).round(2)

      # Fetch items based on the array of IDs
      @items = Item.where(id: ids)

      # Extract costs and quantities from the cart hash
      @costs = cart_hash["costs"]
      @qty = cart_hash["qty"]

      # Calculate savings from discounts
      @savings = @items.select { |item| item.discount > 0.0 }
                       .sum { |item| item.cost * @qty[item.id.to_s].to_i * (item.discount / 100.0) }
                       .round(2)

      # Calculate the price before savings
      @price_before_savings = @savings + @total

      # Extract shipping details if available
      if @user.shipping_details.present? && @user.shipping_details.keys.any?
        @shipping_details = @user.shipping_details
        @address = @shipping_details["address"]
        @billing = @shipping_details["billing"]
        @city = @shipping_details["city"]
        @province = @shipping_details["province"]
        @postal = @shipping_details["postal"]
        @country = @shipping_details["country"]
      else
        # Set default empty values if no shipping details are available
        @address = ""
        @billing = ""
        @city = ""
        @province = ""
        @postal = ""
        @country = ""
      end

      # Extract user details
      @first_name = @user.first_name || ""
      @last_name = @user.last_name || ""
      @phone_number = @user.phone || ""
      @email = @user.email || ""

    # If no cart cookie exists, initialize an empty items array
    else
      @items = []
    end
  end

  # Ensure the user is authenticated
  def authenticate_user!
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "You need to sign in or sign up before continuing."
    end
  end

  # Display the list of orders for the current user
  def order_list
    if current_user.id == params[:id].to_i
      @user = User.find_by(id: params[:id])
      @orders = Order.all
      # Paginate the user's orders
      @pagy, @orders = pagy(@orders.where(user_id: @user.id), items: 5)
    else
      # Redirect to the login page if the user is not authorized
      redirect_to login_path
    end
  end

  # Create a new order
  def create
    logger.debug "Received params: #{params.inspect}"
    @order = Order.new(order_params)

    # Associate the order with the user
    @user = User.find(@order.user_id)
    @user.orders << @order.id
    @user.save

    # Parse the cart cookie
    cart = cookies[:cart]
    cart_hash = JSON.parse(cart)
    ids = cart_hash["ids"] # List of item IDs
    qty = cart_hash["qty"]

    # Set the quantities for the order
    @order.qty = qty

    # Initialize the items array if nil and add item IDs
    @order.items ||= []
    @order.items.concat(ids)

    # Delete the cart cookie after processing
    cookies.delete(:cart)

    # Save the order and redirect accordingly
    if @order.save
      redirect_to cart_path
    else
      redirect_to checkout_path
    end
  end

  # Display a specific order
  def show
    @order = Order.find_by(id: params[:id])
    @orders = Order.all
    @items = Item.all

    if @order
      # Fetch the user and items associated with the order
      @user = User.find(@order.user_id)
      @items = Item.where(id: @order.items)
    else
      # Handle the case where the order is not found
      flash[:alert] = "Order not found"
      redirect_to root_path
    end
  end

  # Mark an order as "Refund in Progress"
  def refund
    @order = Order.find_by(id: params[:id])
    if @order
      @order.order_status = "Refund in Progress"
      @order.save
      redirect_to '/order_list/' + @order.user_id.to_s
    else
      # Handle the case where the order is not found
      flash[:alert] = "Order not found"
      redirect_to root_path
    end
  end

  # Mark an order as "Cancelled"
  def cancel
    @order = Order.find_by(id: params[:id])
    if @order
      @order.order_status = "Cancelled"
      @order.save
      redirect_to '/order_list/' + @order.user_id.to_s
    else
      # Handle the case where the order is not found
      flash[:alert] = "Order not found"
      redirect_to root_path
    end
  end

  # Search for items (placeholder method)
  def search_item
    @orders = Order.all
    @items = Item.all
    @users = User.all
  end

  private

  # Check if the user is logged in
  def logged_in?
    !!current_user
  end

  # Strong parameters for creating an order
  def order_params
    params.permit(:first_name, :last_name, :email_address, :phone_number, :address,
                  :billing_address, :city, :province, :country,
                  :postal_code, :payment_method, :shipping_method,
                  :discount, :tax, :total, :customer_notes,
                  :date_ordered, :created_at, :user_id)
  end

  # Strong parameters for creating or updating an item
  def item_params
    params.require(:item).permit(:title, :cost, :description, :sku, :quantity, :category, :weight, :published, :discount, :rating, paths: [], images: [], video: [])
  end
end
