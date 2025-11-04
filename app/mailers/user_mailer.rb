class UserMailer < ApplicationMailer
  def confirmation
    @user = params.fetch(:user)
    @token = params.fetch(:token)

    mail to: @user.email_address, subject: "Confirm your NU Campus Marketplace account"
  end
end
