class LogController < ApplicationController
  # Display a list of all logs
  def index
    # Fetch all log entries from the database
    @logs = Log.all
  end

  # Show a specific log entry
  def show
    # Find the log entry by its ID
    @log = Log.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # Redirect to the items page with an alert if the log entry is not found
    redirect_to items_path, alert: "Item not found."
  end

  # Create a new log entry
  def create
    # Create a new log entry with the provided data
    @log = Log.create(data)

    # Redirect to the admin activities page after creating the log entry
    redirect_to admin_activities_path
  end
end
