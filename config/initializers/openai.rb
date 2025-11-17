# OpenAI Configuration
# This initializer sets up cost controls and feature flags for AI image description

Rails.application.configure do
  # Feature flag - disable AI generation in production if needed
  config.ai_description_enabled = ENV.fetch("AI_DESCRIPTION_ENABLED", "true") == "true"
  
  # Rate limiting - max descriptions per hour (prevents cost overruns)
  config.ai_description_rate_limit = ENV.fetch("AI_DESCRIPTION_RATE_LIMIT", "100").to_i
  
  # Cache duration - how long to cache descriptions (reduces duplicate API calls)
  config.ai_description_cache_duration = ENV.fetch("AI_DESCRIPTION_CACHE_DURATION", "24").to_i.hours
end
