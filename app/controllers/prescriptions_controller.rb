# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  before_action :set_ap
  before_action :set_installation

  def create
    @prescription = Prescription.create(prescriptions_params)

    if @prescription.save
      flash[:notice] = 'La prescription a été ajoutée'
    else
      flash[:alert] = "La prescription n'a pas été ajoutée - #{@prescription.errors.full_messages.join(', ')}"
    end
    redirect_to installation_ap_path(@installation, @ap)
  end

  def destroy
    @prescription = Prescription.find(params[:id])

    if @prescription.destroy
      flash[:notice] = 'La prescription a bien été supprimée'
    else
      flash[:alert] = "La prescription n'a pas été supprimée."
    end
    redirect_to installation_ap_path(@installation, @ap)
  end

  private

  def set_ap
    @ap = AP.find(params[:ap_id])
  end

  def set_installation
    @installation = Installation.find(params[:installation_id])
  end

  def prescriptions_params
    params.require(:prescription).permit(:reference, :content, :ap_id, :user_id)
  end
end
