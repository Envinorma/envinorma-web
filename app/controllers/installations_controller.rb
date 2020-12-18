class InstallationsController < ApplicationController
  RUBRIQUES = {
    "A": 0,
    "E": 1,
    "D": 2,
    "NC": 3,
    "empty": 4
  }

  include FilterArretes
  before_action :set_installation, only: :show
  before_action :force_json, only: :search

  def index
    @installations = Installation.all
  end

  def show
    @classements = @installation.classements.sort_by { |classement| classement.regime ? RUBRIQUES[classement.regime.to_sym] : RUBRIQUES[:empty]}
    @arretes_list = @installation.classements.map { |classement| classement.arretes }.flatten
    @arretes = []
    @arretes_list.each do |arrete|
      if arrete.enriched_arretes.any?
        @arretes << filter_arretes(arrete, arrete.enriched_arretes).first
      else
        @arretes << arrete
      end
    @arretes
    end

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
