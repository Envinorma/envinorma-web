# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  before_action :set_installation

  def create
    all_params = prescription_params(params)
    build_and_save_prescription(all_params)
      # @prescription = Prescription.create(prescription_params.merge(installation_id: @installation.id, user_id: @user.id))

    @prescription_groups = Prescription.grouped_prescriptions(@user, @installation)
    @prescription = Prescription.new

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
    @prescription_groups = Prescription.grouped_prescriptions(@user, @installation)
    @prescription = Prescription.new
    respond_to do |format|
      format.js { render 'destroy.js.erb' }
      format.json { render json: { success: true }, status: :deleted }
    end
  end

  def delete_many
    prescriptions = if params.key?('alinea_ids')
                      Prescription.from(@user, @installation).where(alinea_id: params[:alinea_ids])
                    else
                      Prescription.from(@user, @installation)
                    end
    prescriptions.destroy_all

    render_destroy
  end

  private

  def set_installation
    @installation = Installation.find(params[:installation_id])
  end

  # def prescription_params
  #   params.require(:prescription).permit(:reference, :content, :alinea_id, :from_am_id, :text_reference)
  # end

  def single_prescription_params(params)
    params.require(:prescription).permit(:reference, :content, :alinea_id, :from_am_id, :user_id, :text_reference,
                                         :rank).merge!(installation_id: @installation.id, user_id: @user.id)
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
                  text_reference: text_reference, content: content, rank: rank, alinea_id: alinea_id }.merge!(installation_id: @installation.id)
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
      if prescription.type == 'AM'
        existing_prescription = Prescription.from(@user, @installation).where(alinea_id: prescription.alinea_id)
        prescription.save if existing_prescription.count.zero?
      else
        prescription.save
      end
    end
  end
end
