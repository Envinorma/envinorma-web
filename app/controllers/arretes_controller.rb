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
    #to do generate .odt with prescriptions
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def prescriptions_params
    params["prescriptions"].permit!
  end
end
