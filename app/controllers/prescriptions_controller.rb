# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  before_action :set_installation

  def create
    Prescription.create(prescription_params)

    @prescriptions = @user.prescriptions_grouped_for(@installation)

    respond_to do |format|
      format.js
      format.json { render json: { success: true }, status: :created }
    end
  end

  def destroy
    prescription = Prescription.find(params[:id])
    prescription.destroy

    render_destroy
  end

  def render_destroy
    @prescriptions = @user.prescriptions_grouped_for(@installation)

    respond_to do |format|
      format.js { render 'destroy.js.erb' }
      format.json { render json: { success: true }, status: :deleted }
    end
  end

  def delete_many
    prescriptions = if params.key?('alinea_ids')
                      @user.prescriptions_for(@installation).where(alinea_id: params[:alinea_ids])
                    else
                      @user.prescriptions_for(@installation)
                    end
    prescriptions.destroy_all

    render_destroy
  end

  private

  def set_installation
    @installation = Installation.find(params[:installation_id])
  end

  def prescription_params
    params[:prescription].key?('contents') ? multiple_prescriptions_params : single_prescription_params
  end

  def multiple_prescriptions_params
    prescription = params[:prescription]

    all_prescriptions_params = []
    prescription[:contents].zip(prescription[:ranks], prescription[:alinea_ids]).each do |content, rank, alinea_id|
      all_prescriptions_params << { reference: prescription[:reference],
                                    from_am_id: prescription[:from_am_id],
                                    text_reference: prescription[:text_reference],
                                    content: content,
                                    rank: rank,
                                    alinea_id: alinea_id }
                                  .merge!(installation_id: @installation.id, user_id: @user.id)
    end
    all_prescriptions_params
  end

  def single_prescription_params
    params.require(:prescription).permit(:reference, :content, :alinea_id, :from_am_id, :user_id, :text_reference,
                                         :rank)
          .merge!(installation_id: @installation.id, user_id: @user.id)
  end
end
