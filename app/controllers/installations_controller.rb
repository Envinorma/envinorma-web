class InstallationsController < ApplicationController
  RUBRIQUES = {
    "A": 0,
    "E": 1,
    "D": 2,
  }

  include FilterArretes
  before_action :set_installation, only: :show
  before_action :force_json, only: :search

  def index
    @installations = Installation.all
  end

  def show
    @arretes = filter_arretes.sort_by {|arrete| RUBRIQUES[arrete.classements.first.regime.to_sym]}
    @classements = @installation.classements.uniq { |classement| classement.rubrique }.sort_by {|classement| RUBRIQUES[classement.regime.to_sym]}
  end

  def search
    q = params[:q].downcase
    # @installations = Installation.where("name ILIKE ? or id ILIKE ?", "%#{q}%", "%#{q}%").limit(5)
    @installations = Installation.where("name ILIKE ?", "%#{q}%").limit(5)
  end


  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def force_json
    request.format = :json
  end
end
