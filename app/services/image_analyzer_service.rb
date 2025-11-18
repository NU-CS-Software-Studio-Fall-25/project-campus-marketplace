require "base64"
require "json"

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
    cached_result = get_cached_result
    return cached_result if cached_result.present?

    # Generate new description
    result = generate_from_api

    # Cache the result
    cache_result(result) if result.present?

    result
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

  def get_cached_result
    cached = Rails.cache.read(cache_key)
    normalize_cached_result(cached)
  end

  def cache_result(result)
    duration = Rails.application.config.ai_description_cache_duration
    Rails.cache.write(cache_key, result, expires_in: duration)
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
              prompt_payload,
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

    content = response.dig("choices", 0, "message", "content")
    parsed = parse_response(content)
    return nil unless parsed[:description].present?

    parsed
  rescue StandardError => e
    Rails.logger.error "ImageAnalyzerService error: #{e.message}"
    nil
  end

  def prompt_payload
    categories = Listing.categories.keys
    {
      type: "text",
      text: <<~PROMPT.squish
        You are helping a college student sell an item on a campus marketplace. Analyze this image and respond ONLY with JSON using this schema:
        {"description":"50-100 word friendly description, 2-3 sentences","category":"one of #{categories.join(", ")}"}.
        Focus on what the item is, its condition, key features, and any visible details that would interest a buyer. Choose the category that best matches the item based solely on the image.
      PROMPT
    }
  end

  def parse_response(raw_content)
    return { description: nil, category: nil } if raw_content.blank?

    cleaned = extract_json_payload(raw_content)
    data = JSON.parse(cleaned)
    description = data["description"].to_s.strip
    category = normalize_category(data["category"])
    { description: description, category: category }
  rescue JSON::ParserError
    Rails.logger.warn "ImageAnalyzerService received unparseable response: #{raw_content}"
    fallback_description = extract_description_from_text(raw_content) || raw_content.to_s.strip.presence
    fallback_category = extract_category_from_text(raw_content)
    {
      description: fallback_description,
      category: fallback_category
    }
  end

  def normalize_cached_result(value)
    case value
    when Hash
      {
        description: value[:description] || value["description"],
        category: normalize_category(value[:category] || value["category"])
      }
    when String
      { description: value, category: nil }
    else
      nil
    end
  end

  def normalize_category(value)
    allowed = Listing.categories.keys
    normalized = value.to_s.downcase
    return nil if normalized.blank?
    allowed.include?(normalized) ? normalized : "other"
  end

  def extract_json_payload(content)
    stripped = content.to_s.strip
    return stripped if stripped.start_with?("{") && stripped.end_with?("}")

    start_index = stripped.index("{")
    end_index = stripped.rindex("}")
    if start_index && end_index && end_index >= start_index
      stripped[start_index..end_index]
    else
      stripped
    end
  end

  def extract_category_from_text(content)
    match = content.to_s.match(/"category"\s*:\s*"([^"]+)"/i)
    return normalize_category(match[1]) if match

    nil
  end

  def extract_description_from_text(content)
    match = content.to_s.match(/"description"\s*:\s*"([^"]+)"/im)
    return match[1].strip if match

    nil
  end

  def openai_api_key
    ENV["OPENAI_API_KEY"] || Rails.application.credentials.dig(:openai, :api_key)
  end
end
