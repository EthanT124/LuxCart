# lib/custom_failure_app.rb
class CustomFailureApp < Devise::FailureApp
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
