class Users::SessionsController < Devise::SessionsController
  # Handle user sign-in
  def create
    # Authenticate the user using Warden and set the resource
    self.resource = warden.authenticate!(auth_options)
    # Set a flash message indicating the user has signed in
    set_flash_message!(:notice, :signed_in)
    # Sign in the user
    sign_in(resource_name, resource)
    # Yield the resource if a block is given (for additional processing)
    yield resource if block_given?
    # Redirect the user to the appropriate path after sign-in
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # Render the sign-in form
  def new
    # Use the default implementation provided by Devise
    super
  end

  # Handle user sign-out
  def destroy
    # Use the default implementation provided by Devise
    super
  end

  # Define authentication options for Warden
  def auth_options
    # Specify the scope and the fallback action if authentication fails
    { scope: resource_name, recall: "#{controller_path}#new" }
  end
end
