# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  before_action :set_installation

  def create
    if params[:amId]
      prescription = Prescription.where(alinea_id: params['id'], user_id: params['userId']).first
      if prescription.nil?
        prescription = Prescription.new(
          reference: params['reference'],
          content: params['content'],
          alinea_id: params['id'],
          from_am_id: params['amId'],
          text_reference: params['amRef'],
          rank: params['rank'],
          user_id: params['userId']
        )
        prescription.save
      end

      respond_to do |format|
        format.json { render json: @params, status: :created }
      end

    else
      @prescription = Prescription.create(prescription_params.merge(installation_id: @installation.id, user_id: @user.id))

      if @prescription.save
        respond_to do |format|
          format.js
          format.json { render json: @prescription, status: :created }
        end
      end
    end
  end

  def destroy
    @prescription = Prescription.find(params[:id])
    if @prescription.destroy
      respond_to do |format|
        format.js
        format.json { render json: @prescription, status: :deleted }
      end
    end
  end

  def remove_prescription
    prescription = Prescription.where(alinea_id: params['id'], user_id: params['userId']).first
    Prescription.delete(prescription.id) unless prescription.nil?
    respond_to do |format|
      format.json { render json: @params }
    end
  end

  private

  def set_installation
    @installation = Installation.find(params[:installation_id])
  end

  def prescription_params
    params.require(:prescription).permit(:reference, :content, :alinea_id, :from_am_id, :text_reference)
  end
end
