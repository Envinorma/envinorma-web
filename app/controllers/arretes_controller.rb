# frozen_string_literal: true

class ArretesController < ApplicationController
  include TopicHelper
  include FilterArretes
  include FicheInspectionHelper
  include OdfHelper
  before_action :set_installation

  def index
    @arretes = []
    params['arrete_ids']&.each do |arrete_id|
      @arretes << Arrete.find(arrete_id)
    end

    @aps = []
    params['ap_ids']&.each do |ap_id|
      @aps << AP.find(ap_id)
    end

    @prescription = Prescription.new
    @alinea_ids = @user.prescription_alinea_ids(@installation)
    @topics_by_section = {}
    @arretes.each do |arrete|
      @topics_by_section[arrete.id] = arrete.topics_by_section
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
