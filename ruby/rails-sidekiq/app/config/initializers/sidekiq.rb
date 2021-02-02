require 'sidekiq/web'

Sidekiq::Web.set :session_secret, Rails.application.secret_key_base
