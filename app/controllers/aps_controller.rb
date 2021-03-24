# frozen_string_literal: true

class APsController < ApplicationController
  before_action :set_ap, only: :show
  before_action :set_installation, only: :show

  def show
    @aps = @installation.APs
    @prescriptions = @user.prescriptions_for(@ap)
    @prescription = Prescription.new
  end

  private

  def set_installation
    @installation = Installation.find(params[:installation_id])
  end

  def set_ap
    @ap = AP.find(params[:id])
  end
end
