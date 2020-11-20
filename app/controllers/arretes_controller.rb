class ArretesController < ApplicationController
  include FilterArretes
  before_action :set_installation

  def index
    @arretes = filter_arretes
  end

  def generate_doc_with_prescriptions
    prescriptions = {}
    prescriptions_params.to_h.each do |key, value|
      value_splitted = value.split('SPLIT')
      prescriptions[key] = {ref: value_splitted.first, value: value_splitted.last}
    end

    #key = "prescription_c7c06a3682298c4b93d3"
    #value = "[\"Chapitre Ier : Dispositions générales\", \"Article 1\"]--Le présent arrêté fixe les prescriptions…"

    # prescriptions: {
    #   prescription_random_id : { ref: ["article 1er", "1.2"], value: "Le présent arrêté fixe"},
    #   prescription_random_id : { ref: ["article 1er", "1.4"], value: "Le présent arrêté fixe"}
    # }

    generate_doc prescriptions
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def prescriptions_params
    params["prescriptions"].permit!
  end

  def generate_doc prescriptions
    template_path = File.join(File.dirname(__FILE__), "../../db/templates/template.odt")

    fiche_inspection = ODFReport::Report.new(template_path) do |r|
      r.add_table("Tableau", prescriptions.values, :header=>true) do |t|
        t.add_column(:ref) { |prescription| prescription[:ref] }
        t.add_column(:prescription) { |prescription| prescription[:value] }
      end
    end

    send_data fiche_inspection.generate,
      type: 'application/vnd.oasis.opendocument.text',
      disposition: 'inline',
      filename: 'fiche_inspection.odt'
  end
end
