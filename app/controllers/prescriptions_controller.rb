# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  before_action :set_installation

  def index
    @prescriptions = @user.prescriptions_grouped_for(@installation)

    respond_to do |format|
      format.js
      format.json { render json: { success: true }, status: :created }
    end
  end

  def create
    checkbox_key = "prescription_checkbox_#{params[:prescription][:alinea_id]}"
    prescription_from_ap = params[:prescription][:from_am_id].nil?

    if params[checkbox_key] || prescription_from_ap
      Prescription.create(prescription_params)
    else
      @user.prescriptions_for(@installation).find_by(alinea_id:
      params[:prescription][:alinea_id]).destroy
    end

    @counter = @user.prescriptions_for(@installation).count

    respond_to do |format|
      format.js
      format.json { render json: { success: true }, status: :created }
    end
  end

  def destroy
    prescription = Prescription.find(params[:id])
    prescription.destroy

    @prescriptions = @user.prescriptions_grouped_for(@installation)
    render_destroy
  end

  def destroy_all
    @user.prescriptions_for(@installation).destroy_all
    render_destroy
  end

  def render_destroy
    @counter = @user.prescriptions_for(@installation).count

    respond_to do |format|
      format.js { render 'destroy.js.erb' }
      format.json { render json: { success: true }, status: :deleted }
    end
  end

  private

  def set_installation
    @installation = Installation.find(params[:installation_id])
  end

  def prescription_params
    params.require(:prescription).permit(:reference, :content, :alinea_id, :from_am_id, :user_id, :text_reference,
                                         :rank)
          .merge!(installation_id: @installation.id, user_id: @user.id)
  end
end
