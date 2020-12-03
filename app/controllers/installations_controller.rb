class InstallationsController < ApplicationController
  RUBRIQUES = {
    "A": 0,
    "E": 1,
    "D": 2,
  }

  include FilterArretes
  before_action :set_installation, except: :index

  def index
    @installations = Installation.all
  end

  def show
    @arretes = filter_arretes.sort_by {|arrete| RUBRIQUES[arrete.classements.first.regime.to_sym]}
    @classements = @installation.classements.uniq { |classement| classement.rubrique }.sort_by {|classement| RUBRIQUES[classement.regime.to_sym]}
  end

  def edit
  end

  def update
    @installation.update(date: params[:installation][:date])
    redirect_to installation_path(@installation)
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end
end
