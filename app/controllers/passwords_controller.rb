class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    if (user = User.find_by(email_address: password_request_params[:email_address]))
      raw_token = user.generate_password_reset!
      PasswordMailer.with(user:, token: raw_token).reset.deliver_later
    end

    redirect_to new_session_path, notice: "If that email is registered, you'll receive password reset instructions shortly."
  end

  def edit
  end

  def update
    if @user.update(password_update_params)
      @user.clear_password_reset!
      @user.sessions.destroy_all
      start_new_session_for(@user)
      redirect_to profile_path, notice: "Your password has been updated and you're signed in."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def password_request_params
      params.fetch(:password, ActionController::Parameters.new).permit(:email_address)
    end

    def password_update_params
      params.fetch(:password, ActionController::Parameters.new).permit(:password, :password_confirmation)
    end

    def set_user_by_token
      email = params[:email] || params.dig(:password, :email_address)
      token = params[:token]
      @user = User.find_by(email_address: email)

      return if @user.present? && token.present? && @user.valid_password_reset_token?(token) && !@user.password_reset_expired?

      @user = nil
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
