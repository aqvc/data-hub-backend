require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HubBackendRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    cookie_domain = ENV["SESSION_COOKIE_DOMAIN"] # e.g. ".datahub.aqvc.com"
    session_options = { key: "_hub_backend_rails_session" }
    session_options[:domain] = cookie_domain if cookie_domain.present?
    session_options[:secure] = true if Rails.env.production?
    session_options[:same_site] = Rails.env.production? ? :none : :lax

    config.session_store :cookie_store, **session_options
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, config.session_options
  end
end
