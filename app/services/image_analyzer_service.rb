require "base64"

class ImageAnalyzerService
  def initialize(image_blob)
    @image_blob = image_blob
  end

  def generate_description
    return nil unless @image_blob.present?
    
    # Check if feature is enabled
    unless feature_enabled?
      Rails.logger.info "AI description generation is disabled"
      return nil
    end
    
    # Check rate limit
    unless check_rate_limit
      Rails.logger.warn "AI description rate limit exceeded"
      return nil
    end

    # Check cache first
    cached_description = get_cached_description
    return cached_description if cached_description.present?

    # Generate new description
    description = generate_from_api
    
    # Cache the result
    cache_description(description) if description.present?
    
    description
  end

  private

  def feature_enabled?
    Rails.application.config.ai_description_enabled
  end

  def check_rate_limit
    limit = Rails.application.config.ai_description_rate_limit
    RateLimiter.check_limit("ai_description", limit, 3600)
  end

  def cache_key
    "ai_description:#{@image_blob.checksum}"
  end

  def get_cached_description
    Rails.cache.read(cache_key)
  end

  def cache_description(description)
    duration = Rails.application.config.ai_description_cache_duration
    Rails.cache.write(cache_key, description, expires_in: duration)
  end

  def generate_from_api
    return nil unless openai_api_key.present?

    client = OpenAI::Client.new(access_token: openai_api_key)

    # Convert image to base64
    image_data = @image_blob.download
    base64_image = Base64.strict_encode64(image_data)
    image_url = "data:#{@image_blob.content_type};base64,#{base64_image}"

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: "You are helping a college student sell an item on a campus marketplace. Analyze this image and generate a brief, appealing product description (2-3 sentences max, around 50-100 words). Focus on: what the item is, its condition, key features, and any visible details that would interest a buyer. Be concise and use a casual, friendly tone appropriate for college students."
              },
              {
                type: "image_url",
                image_url: {
                  url: image_url
                }
              }
            ]
          }
        ],
        max_tokens: 150
      }
    )

    response.dig("choices", 0, "message", "content")&.strip
  rescue StandardError => e
    Rails.logger.error "ImageAnalyzerService error: #{e.message}"
    nil
  end

  def openai_api_key
    ENV["OPENAI_API_KEY"] || Rails.application.credentials.dig(:openai, :api_key)
  end
end
