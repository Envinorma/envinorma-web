class InstallationsController < ApplicationController
  include FilterArretes
  before_action :set_installation, except: :index

  def index
    @installations = Installation.all
  end

  def show
    @arretes = filter_arretes
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
