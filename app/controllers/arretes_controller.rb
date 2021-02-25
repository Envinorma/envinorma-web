# frozen_string_literal: true

class ArretesController < ApplicationController
  include FilterArretes
  before_action :set_installation

  def index
    @arretes = []
    params['arrete_types'].each_with_index do |type, index|
      @arretes << type.constantize.find(params['arrete_ids'][index])
    end
  end

  def generate_doc_with_prescriptions
    prescriptions = {}
    prescriptions_params.to_h.each do |key, value|
      prescriptions[key] = { ref: value['reference'], value: value['content'] } if value['checkbox'] == '1'
    end

    prescriptions_join_by_ref = {}
    prescriptions.group_by { |_k, v| v[:ref] }.each do |key, value|
      prescriptions_join_by_ref[key] = value.map! do |val|
        val.last[:value]
      end.join('<text:line-break/><text:line-break/>')
    end

    generate_doc prescriptions_join_by_ref
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
