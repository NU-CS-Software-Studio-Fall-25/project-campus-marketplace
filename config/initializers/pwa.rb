Rails.application.configure do
  config.x.pwa_cache_version = [
    ENV["PWA_CACHE_VERSION"],
    ENV["SOURCE_VERSION"],
    config.assets.version,
    Rails.env
  ].compact.join("-")
end
