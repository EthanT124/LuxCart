Rails.application.routes.draw do
  root 'home#index'
  # Omniauth callbacks
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :users, only: [:show]
  resources :items do
    resources :reviews, only: [:create, :destroy]
  end
  namespace :admin do
    resources :users, only: [:index, :new, :create, :edit, :update, :destroy]

  end

  resources :notifications, only: [:index, :create, :update, :destroy, :show]

  post 'remove_wishlist', to: 'users#remove_wishlist'

  get 'privacy-policy', to: 'home#privacy_policy', as: 'privacy_policy'
  get 'terms-of-service', to: 'home#terms_of_service', as: 'terms_of_service'

  # Users routes
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/users/:id', to: 'users#show', as: 'user_info'
  get 'user_account/:id', to: 'users#show', as: 'user_account'

  # Define the admin dashboard route
  get '/admin/index', to: 'admin#index', as: 'admin_dashboard'

  # Admin Index
  get '/admin', to: 'admin#index', as: 'admin'

  # Admin Create Page
  get '/admin/new_item', to: 'items#new', as: 'new_admin_item'

  # Admin Create Item Post Request
  post '/admin/create', to: 'admin#create', as: 'admin_create'

  # Admin Management Pages
  get '/admin/admins', to: 'admin#admins', as: 'admin_admins'
  get '/admin/manage_items', to: 'admin#crud_items', as: 'crud_items'

  # Items
  put '/admin/items/:id', to: 'admin#update', as: 'admin_update_item'
  delete '/admin/items/:id', to: 'admin#destroy', as: 'admin_destroy_item'
  delete '/admin/orders/:id', to: 'admin#delete_order', as: 'admin_delete_order'
  put '/orders/refund/:id', to: 'orders#refund', as: 'refund_order'
  put '/orders/cancel/:id', to: 'orders#cancel', as: 'cancel_order'
  # Activities
  get '/admin/activities', to: 'log#index', as: 'activities'
  get '/admin/activities/:id', to: 'log#show'
  post '/admin/activities/create', to: 'admin#create'

  # Notifications
  get '/admin/notifications', to: 'admin#notifications'
  get '/notifications/:id', to: 'notifications#show'
  post '/admin/notifications', to: 'notifications#create'
  put '/admin/notifications/:id', to: 'notifications#update'
  delete '/admin/notifications/:id', to: 'admin#destroy_notifications', as: 'admin_destroy_notification'
  get '/admin/notifications/:id', to: 'notifications#show'
  put '/notifications/read/:id', to: 'notifications#update_status'


  resources :notifications, only: [:create]

  # Items routes
  resources :items

  # Health check route
  get '/up', to: 'rails/health#show', as: :rails_health_check

  # Shop routes
  get '/shop', to: 'items#index'
  get '/shop/index', to: 'items#index'
  get '/shop/:id', to: 'items#show'
  post '/shop', to: 'items#index'

  # Customer Service routes
  get '/contact', to: 'home#contact'
  post '/contact', to: 'home#contact'

  # Rest of Home Page
  get '/services', to: 'home#services'

  # Cart Routes
  get '/cart', to: 'cart#show'

  # Checkout Routes
  get '/cart/checkout', to: 'orders#checkout'
  post '/orders', to: 'orders#create'
  get '/order_list/:id', to: 'orders#order_list'

  # Admin Orders Management
  get '/admin/manage_orders', to: 'admin#crud_orders', as: 'crud_orders'
  put '/admin/orders/:id', to: 'admin#update_order', as: 'update_order'
  get '/admin/orders', to: 'admin#crud_orders', as: 'admin_crud_orders'
  get '/orders/search_item', to: 'orders#search_item'
  get '/orders/:id', to: 'orders#show'

  # Profile
  get '/users/:id', to: 'users#show', as: 'account'
  put '/users/:id', to: 'users#update'
  put '/users/:id/update_shipping', to: 'users#update_shipping'
  put '/users/:id/update_personal', to: 'users#update_personal'
  get '/users/:id/update_shipping_info', to: 'users#update_shipping_info'

  # Reviews
  resources :reviews, only: [:new, :create, :edit, :destroy]
  get '/Reviews/:id', to: 'reviews#show'
  get '/reviews/:id', to: 'reviews#show'
  put '/Reviews/:id', to: 'reviews#update'
  put '/reviews/:id', to: 'reviews#update'
  put '/reviews/yes/:id', to: 'reviews#yes'
  put '/reviews/no/:id', to: 'reviews#no'
  delete '/reviews/:id', to: 'reviews#destroy'

  # User account info
  get '/login/:id', to: 'users#account'
  get '/Login/:id', to: 'users#account'
  post 'update_email', to: 'users#update_email'
  post 'update_password', to: 'users#update_password'
  post 'update_username', to: 'users#update_username'

  # Wishlist
  put '/wishlist/add/:id', to: 'items#add_to_wishlist'
  put '/wishlist/remove/:id', to: 'users#remove_from_wishlist'
  resources :wishlist, only: [:new, :create, :edit, :destroy]
  get '/wishlist/:id', to: 'users#show_wishlist'
  get '/Wishlist/:id', to: 'users#show_wishlist'

  # About Page
  get '/about', to: 'home#About'
  get '/About', to: 'home#About'
end
