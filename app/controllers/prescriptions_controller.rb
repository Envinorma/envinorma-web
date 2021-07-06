# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  include TopicHelper
  before_action :set_installation

  def index
    @prescriptions = @user.prescriptions_grouped_for(@installation)
    @modal = true
    render_prescriptions
  end

  def create_or_delete_from_am
    checkbox_key = "prescription_checkbox_#{params[:prescription][:alinea_id]}"
    checkbox_checked = params[checkbox_key].present?

    if checkbox_checked
      Prescription.create(prescription_params)
    else
      @user.prescriptions_for(@installation).find_by(alinea_id:
      params[:prescription][:alinea_id]).destroy
    end

    render_prescriptions
  end

  def create_from_ap
    prescription_hash = prescription_params
    prescription_hash[:topic] = TopicHelper::AUCUN
    Prescription.create(prescription_hash)
    @from_ap = true

    render_prescriptions
  end

  def destroy
    prescription = Prescription.find(params[:id])
    prescription.destroy

    @prescriptions = @user.prescriptions_grouped_for(@installation)
    render_prescriptions
  end

  def destroy_all
    @user.prescriptions_for(@installation).destroy_all
    render_prescriptions
  end

  def toggle_grouping
    @user.toggle_grouping
    @prescriptions = @user.prescriptions_grouped_for(@installation)
    render_prescriptions
  end

  def render_prescriptions
    @topics = TOPICS
    @counter = @user.prescriptions_for(@installation).count

    respond_to do |format|
      format.js { render 'prescriptions.js.erb' }
    end
  end

  private

  def set_installation
    @installation = Installation.find(params[:installation_id])
  end

  def prescription_params
    params.require(:prescription).permit(:reference, :content, :alinea_id, :from_am_id, :user_id, :text_reference,
                                         :rank, :topic)
          .merge!(installation_id: @installation.id, user_id: @user.id)
  end
end
