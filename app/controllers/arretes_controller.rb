# frozen_string_literal: true

class ArretesController < ApplicationController
  include TopicHelper
  include Parametrization::Parameters
  include FicheInspectionHelper
  before_action :set_installation

  def index
    @url_am_ids, @url_ap_ids = url_ids
    @ams = prepare_ams((params['am_ids'].presence || []).map { |am_id| AM.find(am_id) }, @installation.classements)
    @aps = (params['ap_ids'].presence || []).map { |ap_id| AP.find(ap_id) }
    @prescription = Prescription.new
    @alinea_ids = @user.prescription_alinea_ids(@installation)
    @topics_by_section = {}
    @ams.each do |am|
      @topics_by_section[am.id] = am.topics_by_section
    end

    @topics = TOPICS
  end

  def generate_fiche_inspection
    send_fiche_inspection(@user.prescriptions_for(@installation), @user.consults_precriptions_by_topics?)
  end

  private

  def url_ids
    # -1 is there to avoid default behavior of checking all arretes
    url_am_ids = params['am_ids'].presence || [-1]
    url_ap_ids = params['ap_ids'].presence || [-1]
    [url_am_ids, url_ap_ids]
  end

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def prescriptions_params
    params['prescriptions'].permit!
  end
end
