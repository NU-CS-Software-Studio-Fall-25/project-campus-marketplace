require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MarketplaceApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[ assets tasks ])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # AI Image Description Feature
    config.ai_description_enabled = ENV.fetch("AI_DESCRIPTION_ENABLED", "true") == "true"
    config.ai_description_rate_limit = ENV.fetch("AI_DESCRIPTION_RATE_LIMIT", "50").to_i
    config.ai_description_cache_duration = ENV.fetch("AI_DESCRIPTION_CACHE_DURATION", "7").to_i.days

    # Content Safety Feature
    config.content_safety_enabled = ENV.fetch("CONTENT_SAFETY_ENABLED", "true") == "true"
  end
end
