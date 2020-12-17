class InstallationsController < ApplicationController
  RUBRIQUES = {
    "A": 0,
    "E": 1,
    "D": 2,
    "empty": 3
  }

  include FilterArretes
  before_action :set_installation, only: :show
  before_action :force_json, only: :search

  def index
    @installations = Installation.all
  end

  def show
    @classements = @installation.classements.sort_by { |classement| classement.regime ? RUBRIQUES[classement.regime.to_sym] : RUBRIQUES[:empty]}
    @arretes = @installation.classements.map { |classement| classement.arretes }.flatten
  end

  def search
    q = params[:q].downcase
    @installations = Installation.where("name ILIKE ? or s3ic_id ILIKE ?", "%#{q}%", "%#{q}%").limit(10)
  end


  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def force_json
    request.format = :json
  end
end
