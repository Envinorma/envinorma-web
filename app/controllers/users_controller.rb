class UsersController < ApplicationController
  def show
    if @user
      @installations = @user.installations
    else
      redirect_to root_path
    end
  end
end
