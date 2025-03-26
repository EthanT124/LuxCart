# frozen_string_literal: true

Devise.setup do |config|
  # Configure the e-mail address which will be shown in Devise::Mailer
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  # Load and configure the ORM. Supports :active_record (default) and :mongoid by default.
  require 'devise/orm/active_record'

  # Configure which keys are used when authenticating a user.
  config.authentication_keys = [:username]
  config.case_insensitive_keys = [:username, :email]
  config.strip_whitespace_keys = [:email]
  OmniAuth.config.logger = Rails.logger
  # Skip session storage for HTTP Auth
  config.skip_session_storage = [:http_auth]

  # Configure the cost for hashing the password
  config.stretches = Rails.env.test? ? 1 : 12

  # Reconfirmable configuration
  config.reconfirmable = true

  # Rememberable configuration
  config.expire_all_remember_me_on_sign_out = true

  # Validatable configuration
  config.password_length = 1..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # Recoverable configuration
  config.reset_password_within = 6.hours

  # Sign out via DELETE method
  config.sign_out_via = :delete

  # OmniAuth configuration
  config.omniauth :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
    token_params: { parse: :json },
    client_options: {
      site: 'https://graph.facebook.com/v17.0',
      authorize_url: "https://www.facebook.com/v17.0/dialog/oauth"
    },
    scope: 'email',
    info_fields: 'email,name',
    secure_image_url: true,
    image_size: 'large'

  # CSRF Protection
  OmniAuth.config.allowed_request_methods = %i[get post]


  # Remove the line below as it causes the error:

  OmniAuth.config.logger = Rails.logger

  config.omniauth :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: 'userinfo.email,userinfo.profile',
    prompt: 'select_account',
    access_type: 'offline'
  }
  config.omniauth :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: 'user:email'

  # Hotwire/Turbo configuration
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
