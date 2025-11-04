class UserMailer < ApplicationMailer
  def confirmation
    @user = params.fetch(:user)
    @token = params.fetch(:token)

    mail to: @user.email_address, subject: "Confirm your NU Campus Marketplace account"
  end

  def goodbye
    @user = params.fetch(:user)

    mail to: @user.email_address, subject: "Your NU Campus Marketplace account has been deleted"
  end
end
