# frozen_string_literal: true

class ArretesController < ApplicationController
  include TopicHelper
  include FilterArretes
  include FicheInspectionHelper
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
    @arrete_topics = {}
    @arretes.each do |arrete|
      @arrete_topics[arrete.id] = arrete.topics
    end

    @topics = TOPICS
  end

  def generate_doc_with_prescriptions
    groups = helpers.merge_prescriptions(@user.prescriptions, @user.group_prescriptions_by_topic)
    generate_doc(groups, @user.group_prescriptions_by_topic)
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def prescriptions_params
    params['prescriptions'].permit!
  end
end
