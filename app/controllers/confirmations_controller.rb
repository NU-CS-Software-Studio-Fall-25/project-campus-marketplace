class ConfirmationsController < ApplicationController
  allow_unauthenticated_access only: %i[show create]

  def show
    user = User.find_by(email_address: params[:email])

    if user.present? && user.pending_confirmation? && valid_token?(user, params[:token])
      user.confirm!
      start_new_session_for(user)
      redirect_to profile_path, notice: "Your email has been confirmed!"
    else
      redirect_to new_session_path, alert: "Confirmation link is invalid or has expired."
    end
  end

  def create
    user = User.find_by(email_address: confirmation_params[:email_address])

    if user.present? && user.pending_confirmation?
      token = user.generate_confirmation_token!
      UserMailer.with(user:, token: token).confirmation.deliver_later
      redirect_to new_session_path, notice: "We just sent a new confirmation email."
    else
      redirect_to new_session_path, alert: "We couldn't find an account that needs confirmation with that email."
    end
  end

  private
    def confirmation_params
      params.require(:confirmation).permit(:email_address)
    end

    def valid_token?(user, token)
      return false if token.blank?

      user.valid_confirmation_token?(token) && !user.confirmation_token_expired?
    end
end
