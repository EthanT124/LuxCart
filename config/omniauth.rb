# OmniAuth Configuration
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
OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.protect_from_forgery = true
