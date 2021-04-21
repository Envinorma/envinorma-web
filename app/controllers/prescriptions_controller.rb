# frozen_string_literal: true

class PrescriptionsController < ApplicationController
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
      @prescription = Prescription.create(prescription_params)

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

  def prescription_params
    params.require(:prescription).permit(:reference, :content, :alinea_id, :from_am_id, :user_id, :text_reference)
  end
end
