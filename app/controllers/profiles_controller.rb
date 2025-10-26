class ProfilesController < ApplicationController
  def show
    @user = current_user
    @listing_count = @user.listings.count
  end

  def update
    @user = current_user
    clean_params = profile_params
    if clean_params.key?(:phone_number) && clean_params[:phone_number].blank?
      clean_params[:phone_number] = nil
    end

    if @user.update(clean_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      @listing_count = @user.listings.count
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  private
    def profile_params
      params.fetch(:user, {}).permit(:phone_number)
    end
end
