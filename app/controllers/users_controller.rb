# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    if @user
      return redirect_if_no_installation if @user.installations.blank?

      @installations = @user.installations
    else
      flash[:alert] = 'Désolé, vous n’êtes pas autorisé à accéder à cette page'
      redirect_to root_path
    end
  end

  private

  def redirect_if_no_installation
    flash[:alert] = "Désolé, vous n’avez pas d'installation"
    redirect_to root_path
  end
end
