class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      token = @user.generate_confirmation_token!
      UserMailer.with(user: @user, token: token).confirmation.deliver_later
      redirect_to new_session_path, notice: "Check your email to confirm your account before signing in."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation, :username, :phone_number, :first_name, :last_name)
    end
end
