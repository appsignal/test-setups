require 'sidekiq/web'

Sidekiq::Extensions.enable_delay!

Sidekiq::Web.set :session_secret, Rails.application.secret_key_base
