class RateLimiter
  REDIS_KEY_PREFIX = "rate_limit"
  
  def self.check_limit(key, limit, period_seconds = 3600)
    # Use Rails cache (works with memory store in dev, Redis in production)
    cache_key = "#{REDIS_KEY_PREFIX}:#{key}"
    
    current_count = Rails.cache.read(cache_key) || 0
    
    if current_count >= limit
      return false
    end
    
    # Increment counter
    Rails.cache.write(cache_key, current_count + 1, expires_in: period_seconds)
    true
  end
  
  def self.remaining(key, limit, period_seconds = 3600)
    cache_key = "#{REDIS_KEY_PREFIX}:#{key}"
    current_count = Rails.cache.read(cache_key) || 0
    [limit - current_count, 0].max
  end
end
