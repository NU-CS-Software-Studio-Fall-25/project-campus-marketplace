require "base64"
require "json"

class ContentSafetyService
  # Categories of harmful content to check for
  HARMFUL_CATEGORIES = %w[
    violence
    hate
    harassment
    self-harm
    sexual
    illicit
  ].freeze

  # Additional keywords for campus-specific prohibited items
  PROHIBITED_KEYWORDS = [
    # Drugs and controlled substances
    "drugs", "weed", "marijuana", "cannabis", "cocaine", "heroin", "meth",
    "ecstasy", "mdma", "lsd", "psychedelic", "prescription pills", "adderall",
    "xanax", "oxycodone", "percocet", "vicodin",
    # Alcohol (underage sales)
    "beer", "wine", "vodka", "whiskey", "liquor", "alcohol", "booze",
    "tequila", "rum", "gin", "champagne",
    # Weapons
    "gun", "firearm", "pistol", "rifle", "shotgun", "weapon", "knife",
    "sword", "ammunition", "bullets", "explosive",
    # Other prohibited items
    "fake id", "counterfeit", "stolen", "pirated"
  ].freeze

  def initialize(listing)
    @listing = listing
  end

  def check_safety
    return safe_result unless feature_enabled?

    # Check both text content and image
    text_result = check_text_content
    image_result = check_image_content if @listing.image.attached?

    # Combine results
    combine_results(text_result, image_result)
  rescue StandardError => e
    Rails.logger.error "ContentSafetyService error: #{e.message}"
    safe_result # Fail open - don't block legitimate listings on errors
  end

  private

  def feature_enabled?
    Rails.application.config.content_safety_enabled
  end

  def check_text_content
    # First check for obvious prohibited keywords
    content = "#{@listing.title} #{@listing.description}".downcase

    prohibited_match = PROHIBITED_KEYWORDS.find do |keyword|
      content.include?(keyword.downcase)
    end

    if prohibited_match
      return unsafe_result("Contains prohibited keyword: #{prohibited_match}")
    end

    # Then use OpenAI moderation API for more nuanced checking
    check_with_openai_moderation
  end

  def check_image_content
    return safe_result unless @listing.image.attached?
    return safe_result unless openai_api_key.present?

    client = OpenAI::Client.new(access_token: openai_api_key)

    # Convert image to base64
    image_data = @listing.image.download
    base64_image = Base64.strict_encode64(image_data)
    image_url = "data:#{@listing.image.content_type};base64,#{base64_image}"

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: <<~PROMPT.squish
                  You are a content moderator for a college campus marketplace.
                  Analyze this image and determine if it contains any prohibited items:
                  - Drugs or controlled substances (marijuana, pills, paraphernalia, etc.)
                  - Alcohol or alcoholic beverages
                  - Weapons (guns, knives, ammunition, etc.)
                  - Counterfeit or stolen goods
                  - Any other items that would be inappropriate for a campus marketplace

                  Respond ONLY with JSON: {"safe":true/false,"reason":"explanation if unsafe"}
                PROMPT
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
        max_tokens: 100
      }
    )

    content = response.dig("choices", 0, "message", "content")
    parse_image_response(content)
  rescue StandardError => e
    Rails.logger.error "Image safety check error: #{e.message}"
    safe_result
  end

  def check_with_openai_moderation
    return safe_result unless openai_api_key.present?

    client = OpenAI::Client.new(access_token: openai_api_key)

    text = "#{@listing.title}\n#{@listing.description}"

    response = client.moderations(
      parameters: {
        input: text
      }
    )

    result = response.dig("results", 0)
    return safe_result unless result

    if result["flagged"]
      categories = result["categories"].select { |_k, v| v }.keys
      return unsafe_result("Flagged for: #{categories.join(', ')}")
    end

    safe_result
  rescue StandardError => e
    Rails.logger.error "OpenAI moderation error: #{e.message}"
    safe_result
  end

  def parse_image_response(content)
    cleaned = extract_json_from_response(content)
    data = JSON.parse(cleaned)

    if data["safe"] == false
      unsafe_result(data["reason"] || "Image contains prohibited content")
    else
      safe_result
    end
  rescue JSON::ParserError
    Rails.logger.warn "Could not parse image safety response: #{content}"
    safe_result
  end

  def extract_json_from_response(content)
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

  def combine_results(text_result, image_result)
    # If either check fails, the listing is unsafe
    return text_result unless text_result[:safe]
    return image_result if image_result.present? && !image_result[:safe]

    safe_result
  end

  def safe_result
    { safe: true, reason: nil }
  end

  def unsafe_result(reason)
    { safe: false, reason: reason }
  end

  def openai_api_key
    ENV["OPENAI_API_KEY"] || Rails.application.credentials.dig(:openai, :api_key)
  end
end
