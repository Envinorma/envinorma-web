# frozen_string_literal: true

class ArretesController < ApplicationController
  include TopicHelper
  include FilterAMs
  include FicheInspectionHelper
  include OdfHelper
  before_action :set_installation

  def index
    @ams = []
    params['am_ids']&.each do |am_id|
      @ams << AM.find(am_id)
    end

    @aps = []
    params['ap_ids']&.each do |ap_id|
      @aps << AP.find(ap_id)
    end

    @prescription = Prescription.new
    @alinea_ids = @user.prescription_alinea_ids(@installation)
    @topics_by_section = {}
    @ams.each do |am|
      @topics_by_section[am.id] = am.topics_by_section
    end

    @topics = TOPICS
  end

  def generate_doc_with_prescriptions
    groups = merge_prescriptions(@user.prescriptions, @user.consults_precriptions_by_topics?)
    generate_doc(groups, @user.consults_precriptions_by_topics?)
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def prescriptions_params
    params['prescriptions'].permit!
  end
end
