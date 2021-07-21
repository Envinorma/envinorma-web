# frozen_string_literal: true

class ClassementsController < ApplicationController
  before_action :set_installation
  before_action :user_can_modify_installation, only: %i[new create]

  def new
    @classement = Classement.new
  end

  def create
    @classement = Classement.create(classement_params)

    if @classement.save
      flash[:notice] = 'Le classement a été ajouté'
      redirect_to installation_path(@installation)
    else
      flash[:alert] = "Le classement n'a pas été ajouté"
      render 'new'
    end
  end

  def destroy; end

  private

  def set_installation
    @installation = Installation.find(params[:installation_id])
  end

  def classement_params
    params.require(:classement).permit(
      :rubrique, :regime, :date_autorisation, :date_mise_en_service
    ).merge!(installation_id: @installation.id)
  end
end
