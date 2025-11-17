require "faraday"
require "json"

module Ai
  class GeminiDescriptionService
    ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent".freeze
    DEFAULT_TEMPERATURE = 0.4
    DEFAULT_MAX_OUTPUT_TOKENS = 200

    def initialize(http: default_connection, api_key: nil)
      @http = http
      credentials_key = Rails.application.credentials.dig(:google, :gemini_api_key) rescue nil
      @api_key = api_key || credentials_key || ENV["GEMINI_API_KEY"]
    end

    def call(title:, notes:, tone: "friendly")
      return if title.blank? || @api_key.blank?

      payload = {
        contents: [
          {
            role: "user",
            parts: [
              { text: build_prompt(title: title, notes: notes, tone: tone) }
            ]
          }
        ],
        generationConfig: {
          temperature: DEFAULT_TEMPERATURE,
          maxOutputTokens: DEFAULT_MAX_OUTPUT_TOKENS
        }
      }

      response = @http.post do |request|
        request.url(ENDPOINT, key: @api_key)
        request.body = JSON.generate(payload)
      end

      return parse_response(response) if response.success?

      Rails.logger.error("Gemini API error #{response.status}: #{response.body}")
      nil
    rescue Faraday::Error => e
      Rails.logger.error("Gemini request failed: #{e.message}")
      nil
    end

    private

    def default_connection
      Faraday.new(headers: { "Content-Type" => "application/json" })
    end

    def build_prompt(title:, notes:, tone:)
      <<~PROMPT
        You help Northeastern University students write marketplace listings.
        Create a #{tone} description under 500 characters.
        Item: #{title}
        Seller notes: #{notes.presence || "None provided"}
      PROMPT
    end

    def parse_response(response)
      data = JSON.parse(response.body)
      data.dig("candidates", 0, "content", "parts", 0, "text")&.strip
    rescue JSON::ParserError => e
      Rails.logger.error("Gemini response parse failed: #{e.message}")
      nil
    end
  end
end
