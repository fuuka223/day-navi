class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @locations = Location.all
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to root_path(@user)
    else
      @locations = Location.all
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :location_id)
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
