class PasswordMailer < ApplicationMailer
  def reset
    @user = params.fetch(:user)
    @token = params.fetch(:token)

    mail to: @user.email_address, subject: "Reset your password"
  end
end
