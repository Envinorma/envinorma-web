class ArretesController < ApplicationController
  before_action :set_installation

  def index
    @arretes = @installation.arretes
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end
end
