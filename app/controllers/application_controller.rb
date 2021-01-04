class ApplicationController < ActionController::Base
  before_action :set_user_if_needed

  private

  def set_user_if_needed
    @user = User.find(session[:user_id]) if session[:user_id]
  end
end
