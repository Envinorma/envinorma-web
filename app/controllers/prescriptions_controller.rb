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
    if prescription_hash[:content].length.zero? || prescription_hash[:reference].length.zero?
      @message = 'Les champs contenu et référence ne doivent pas être vides.'
      respond_to do |format|
        format.js { render 'shared/alert.js.erb' }
      end
    else
      Prescription.create(prescription_hash)
      @from_ap = true
      render_prescriptions
    end
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
    @prescriptions_might_be_deprecated = prescriptions_might_be_deprecated?

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
                                         :rank, :topic, :is_table)
          .merge!(installation_id: @installation.id, user_id: @user.id)
  end

  def prescriptions_might_be_deprecated?
    # Prescriptions are deprecated if any of them have been selected before the last update of the AM
    prescriptions = @user.prescriptions_for(@installation).pluck(:from_am_id, :created_at)
    dates_by_am_id = Hash.new([])
    prescriptions.each { |am_id, date| dates_by_am_id[am_id] += [date] if am_id.present? }
    dates_by_am_id.any? { |am_id, dates| AM.find(am_id).content_updated_at > dates.min if AM.exists?(id: am_id) }
  end
end
