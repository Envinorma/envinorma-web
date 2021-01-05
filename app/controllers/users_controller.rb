class UsersController < ApplicationController
  def show
    if @user
      @installations = @user.installations
    else
      flash[:alert] = "Désolé, vous n’êtes pas autorisé à accéder à cette page"
      redirect_to root_path
    end
  end
end
