# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  def delete_prescriptions(params)
    prescriptions = if params.key?('alinea_ids')
                      Prescription.from_user_and_installation(@user).where(alinea_id: params[:alinea_ids])
                    else
                      Prescription.from_user_and_installation(@user)
                    end
    prescriptions.destroy_all
  end

  def create
    if params[:delete]
      delete_prescriptions(params)
    else
      all_params = prescription_params(params)
      build_and_save_prescription(all_params)
    end

    @prescription_groups = Prescription.grouped_prescriptions(@user)
    @prescription = Prescription.new

    respond_to do |format|
      format.js
      format.json { render json: { success: true }, status: :created }
    end
  end

  def destroy
    prescription = Prescription.find(params[:id])
    prescription.destroy

    @prescription_groups = Prescription.grouped_prescriptions(@user)
    @prescription = Prescription.new
    respond_to do |format|
      format.js
      format.json { render json: { success: true }, status: :deleted }
    end
  end

  private

  def single_prescription_params(params)
    params.require(:prescription).permit(:reference, :content, :alinea_id, :from_am_id, :user_id, :text_reference,
                                         :rank)
  end

  def multiple_prescriptions_params(params)
    data = params[:prescription]
    reference = data[:reference]
    from_am_id = data[:from_am_id]
    user_id = data[:user_id]
    text_reference = data[:text_reference]
    result = []
    data[:contents].zip(data[:ranks], data[:alinea_ids]).each do |content, rank, alinea_id|
      result << { reference: reference, from_am_id: from_am_id, user_id: user_id,
                  text_reference: text_reference, content: content, rank: rank, alinea_id: alinea_id }
    end
    result
  end

  def prescription_params(params)
    prescriptions = params[:prescription]
    prescriptions.key?('contents') ? multiple_prescriptions_params(params) : [single_prescription_params(params)]
  end

  def build_and_save_prescription(prescription_hashes)
    prescription_hashes.each do |prescription_hash|
      prescription = Prescription.new(prescription_hash)
      existing_prescription = Prescription.from_user_and_installation(@user).where(alinea_id: prescription.alinea_id)
      prescription.save if existing_prescription.count.zero?
    end
  end
end
