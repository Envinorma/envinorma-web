class ArretesController < ApplicationController
  before_action :set_installation

  def index
    @arretes = @installation.arretes
  end

  def generate_doc_with_prescriptions
    prescriptions = prescriptions_params.to_h
    prescriptions_text = []
    prescriptions.each do |id, text|
      prescriptions_text << text
    end
    generate_doc prescriptions_text
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def generate_doc prescriptions_text
    template_path = File.join(File.dirname(__FILE__), "../../db/templates/template.odt")

    i = 0
    fiche_inspection = ODFReport::Report.new(template_path) do |r|
      r.add_table("Tableau", prescriptions_text, :header=>true) do |t|
        t.add_column(:id) { |item| "#{i += 1}" }
        t.add_column(:prescription) { |item| "#{item}" }
      end
    end

    send_data fiche_inspection.generate,
      type: 'application/vnd.oasis.opendocument.text',
      disposition: 'inline',
      filename: 'fiche_inspection.odt'
  end

  def prescriptions_params
    params["prescriptions"].permit!
  end
end
