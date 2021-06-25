# frozen_string_literal: true

class ArretesController < ApplicationController
  include FilterArretes
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
    @prescriptions = @user.prescriptions_grouped_for(@installation)
    @alinea_ids = @user.prescription_alinea_ids(@installation)
    @arrete_topics = {}
    @arretes.each do |arrete|
      @arrete_topics[arrete.id] = arrete.topics
    end

    @topics = {
      DISPOSITIONS_GENERALES: 'Dispositions générales',
      IMPLANTATION_AMENAGEMENT: 'Implantation - aménagement',
      EXPLOITATION: 'Exploitation',
      RISQUES: 'Risques',
      EAU: 'Eau',
      AIR_ODEURS: 'Air - odeurs',
      DECHETS: 'Déchets',
      BRUIT_VIBRATIONS: 'Bruit - vibrations',
      FIN_EXPLOITATION: 'Fin d\'exploitation'
    }.freeze
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
