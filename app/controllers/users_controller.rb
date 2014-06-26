class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    if @user.id != current_user.id
      redirect_to :back, alert: 'Access denied.'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, notice: 'User updated.'
    else
      redirect_to users_path, alert: 'Unable to update user.'
    end
  end

  def destroy
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, notice: 'User deleted.'
    else
      redirect_to users_path, notice: "Can't delete yourself."
    end
  end

  private

  def secure_params
    params.require(:user).permit(:role)
  end
end
