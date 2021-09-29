# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_user_if_needed
  before_action :create_guest_if_needed

  private

  def set_user_if_needed
    if cookies[:user_id] && User.exists?(cookies[:user_id])
      @user = User.find(cookies[:user_id])
      @user.update(updated_at: Time.zone.now) # update user's last visit
    else
      cookies.delete(:user_id)
    end
  end

  def create_guest_if_needed
    return if cookies[:user_id]

    @user = User.create
    cookies[:user_id] = { value: @user.id, expires: 5.years.from_now }
  end

  def user_can_modify_installation
    return if @user.present? && @installation.user_id == @user.id

    flash[:alert] = 'Désolé, vous n’êtes pas autorisé à accéder à cette page'
    redirect_to root_path
  end

  def user_can_visit_installation
    return if @installation.user_id.nil?

    user_can_modify_installation
  end
end
