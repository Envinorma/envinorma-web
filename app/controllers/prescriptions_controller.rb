# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  def create
    @prescription = Prescription.create(prescription_params)
    return unless @prescription.save

    @prescription_groups = Prescription.from_user(@user)

    respond_to do |format|
      format.js
      format.json { render json: @prescription, status: :created }
    end
  end

  def destroy
    @prescription = Prescription.find(params[:id])
    return unless @prescription.destroy

    @prescription_groups = Prescription.from_user(@user)
    respond_to do |format|
      format.js
      format.json { render json: @prescription, status: :deleted }
    end
  end

  private

  def prescription_params
    params.require(:prescription).permit(:reference, :content, :alinea_id, :from_am_id, :user_id, :text_reference,
                                         :rank)
  end
end
