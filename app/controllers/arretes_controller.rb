# frozen_string_literal: true

class ArretesController < ApplicationController
  include FilterArretes
  before_action :set_installation

  def index
    @arretes = []
    params['arrete_ids']&.each do |arrete_id|
      @arretes << Arrete.find(arrete_id)
    end

    @prescription = Prescription.new
    @prescriptions = Prescription.from_aps(@user)
    @aps = @installation.retrieve_aps
  end

  def generate_doc_with_prescriptions
    prescriptions_array_of_hashes = []

    @user.prescriptions.each do |prescription|
      prescriptions_array_of_hashes << { prescription.reference => prescription.content }
    end

    prescriptions_joined_by_key = {}

    prescriptions_array_of_hashes.each do |prescription|
      if prescriptions_joined_by_key.key?(prescription.keys.first)
        prescriptions_joined_by_key[prescription.keys.first] += '<text:line-break/><text:line-break/>' + prescription.values.first
      else
        prescriptions_joined_by_key.merge!({ prescription.keys.first => prescription.values.first })
      end
    end

    generate_doc(prescriptions_joined_by_key)
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def prescriptions_params
    params['prescriptions'].permit!
  end

  def merge_prescriptions_with_same_ref(prescriptions)
    prescriptions_joined_by_ref = {}
    prescriptions.group_by { |_k, v| v[:ref] }.each do |key, value|
      prescriptions_joined_by_ref[key] = value.map! do |val|
        val.last[:value]
      end.join('<text:line-break/><text:line-break/>')
    end
    prescriptions_joined_by_ref
  end

  def generate_doc(prescriptions)
    template_path = File.join(File.dirname(__FILE__), '../../db/templates/template.odt')

    fiche_inspection = ODFReport::Report.new(template_path) do |r|
      r.add_table('Tableau', prescriptions, header: true) do |t|
        t.add_column(:ref, &:first)
        t.add_column(:prescription, &:last)
      end
    end

    send_data fiche_inspection.generate,
              type: 'application/vnd.oasis.opendocument.text',
              disposition: 'inline',
              filename: 'fiche_inspection.odt'
  end
end
