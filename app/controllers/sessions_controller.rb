class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create google failure ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      if user.confirmed?
        start_new_session_for user
        redirect_to after_authentication_url
      else
        token = user.generate_confirmation_token!
        UserMailer.with(user:, token: token).confirmation.deliver_later
        redirect_to new_session_path, alert: "Please confirm your email address. We just sent you a new confirmation link."
      end
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  def google
    auth = request.env["omniauth.auth"]

    if auth.blank?
      Rails.logger.error("[sessions#google] Empty OmniAuth payload")
      redirect_to new_session_path, alert: "We couldn't sign you in with Google. Please try again."
      return
    end

    email = auth.dig("info", "email").to_s.downcase
    allowed_domains = ENV.fetch("GOOGLE_ALLOWED_EMAIL_DOMAINS", "u.northwestern.edu").split(",").map { |domain| domain.strip.downcase }.reject(&:blank?)

    unless allowed_domains.any? { |domain| email.end_with?("@#{domain}") }
      Rails.logger.warn("[sessions#google] Attempted Google login with unauthorized domain: #{email}")
      redirect_to new_session_path, alert: "Please sign in with your Northwestern email (#{allowed_domains.join(", ")})."
      return
    end

    user = User.from_google(auth)
    start_new_session_for user
    redirect_to after_authentication_url, notice: "Signed in with Google."
  rescue StandardError => e
    Rails.logger.error("[sessions#google] #{e.class}: #{e.message}")
    redirect_to new_session_path, alert: "We couldn't sign you in with Google. Please try again."
  end

  def failure
    message = params[:message].presence || "authentication failed"
    redirect_to new_session_path, alert: "Google sign-in failed: #{message.humanize}."
  end
end
