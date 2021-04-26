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
    @prescriptions = Prescription.from(@user, @installation)
    @aps = @installation.retrieve_aps
  end

  def generate_doc_with_prescriptions
    groups = helpers.merge_prescriptions_with_same_ref(@user.prescriptions)
    generate_doc(groups)
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def prescriptions_params
    params['prescriptions'].permit!
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
