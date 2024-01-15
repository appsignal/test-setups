require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.hosts << "app"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.cache_store = [:solid_cache, :expiry_method => :pilotes]
    config.active_record.encryption.key_derivation_salt = "fdsfdsdfhdgs"
    config.active_record.encryption.primary_key = "d65bb9ea5370615322a8b970298001dd379f33eff9d8f7e14b93d1b27e35b9438ccc4c0bd16b1e1f2cd5c6a5f38c0ecc0b58d875754b94a642d7c01bf1cedde4bd0c91748304e2347b09f67dfcfa0b25a5f5c7f73c7d6238bb256aebba2e9b4ca050edfcf8f5361e5eb078a9084bc13ede8f810d669d1d22737f55744d68f98100ac24f35da228e3eebcdec6c993c1af4a9e0ebfe718263ed640ac91d4be9378fb26cd5c323f3289f41e0060252d99f5a114d9eb78d2685cc315248458c214d1bb8d4453e9a697784cc53663f297ed039d6796a17f11065aea47788096e54580ffb8ae1a531c0a53317c01abaf2738e342a5bcb47d67e60211e7fc62ce59ab9e"
  end
end
