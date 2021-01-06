class ApplicationController < ActionController::Base
  before_action :set_user_if_needed

  private

  def set_user_if_needed
    if session[:user_id] && User.exists?(session[:user_id])
      @user = User.find(session[:user_id])
    end
  end
end
