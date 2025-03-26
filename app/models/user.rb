class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :omniauthable, omniauth_providers: %i[github google_oauth2 facebook]

  def self.from_omniauth(auth)
    email = auth.info.email || "#{auth.uid}@github.com" # Use a generated email if missing
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = email if user.email.blank? # Set email if blank
    user.username = auth.info.nickname || auth.info.name if user.username.blank?
    user.password = Devise.friendly_token[0, 20] if user.new_record? # Set password if new user
    user.save
    user
  end
end
