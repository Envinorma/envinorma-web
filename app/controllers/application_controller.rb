class ApplicationController < ActionController::Base
  before_action :set_user_if_needed

  private

  def set_user_if_needed
    if session[:user_id] && User.exists?(session[:user_id])
      @user = User.find(session[:user_id])
    end
  end

  def create_guest_if_needed
    return if session[:user_id]
    @user = User.create
    session[:user_id] = @user.id
  end

  def check_if_authorized_user
    return if @installation.user_id.nil?
    return if @user.present? && @installation.user_id == @user.id
    flash[:alert] = "Désolé, vous n’êtes pas autorisé à accéder à cette page"
    redirect_to root_path
  end
end
