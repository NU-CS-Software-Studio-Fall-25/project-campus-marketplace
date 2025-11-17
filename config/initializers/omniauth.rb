require "omniauth"

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true

google_client_id = ENV["GOOGLE_CLIENT_ID"]
google_client_secret = ENV["GOOGLE_CLIENT_SECRET"]

if google_client_id.present? && google_client_secret.present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
             google_client_id,
             google_client_secret,
             {
               scope: "email,profile",
               prompt: "select_account",
               access_type: "offline",
               hd: ENV["GOOGLE_OAUTH_ALLOWED_DOMAIN"]
             }.compact
  end
else
  Rails.logger.warn("[omniauth] GOOGLE_CLIENT_ID/GOOGLE_CLIENT_SECRET not configured; Google sign-in disabled.")
end
