# frozen_string_literal: true

class InstallationsController < ApplicationController
  include FilterArretes
  include ApplicationHelper
  before_action :set_installation, except: %i[index search]
  before_action :force_json, only: :search
  before_action :check_if_authorized_user, only: %i[show edit update]

  def index
    @installations = Installation.not_attached_to_user
  end

  def show
    @aps = @installation.retrieve_aps

    @classements = @installation.classements.sort_by do |classement|
      classement.regime.present? ? REGIMES[classement.regime.to_sym] : REGIMES[:empty]
    end

    @arretes = compute_applicable_arretes_list(@classements)
  end

  def edit
    return if @installation.user_id == @user.id

    if @user.already_duplicated_installation?(@installation)
      redirect_to edit_installation_path(@user.retrieve_duplicated_installation(@installation))
    else
      installation_duplicated = @installation.duplicate!(@user)
      redirect_to edit_installation_path(installation_duplicated)
    end
  end

  def update
    if @installation.update(classement_params)
      flash[:notice] = "L'installation a bien été mise à jour"
      redirect_to installation_path(@installation)
    else
      flash[:alert] = "L'installation n'a pas été mise à jour"
      render :edit
    end
  end

  def search
    args = helpers.build_query(params[:q])
    @installations = Installation.where(args).not_attached_to_user.limit(10)
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def force_json
    request.format = :json
  end

  def classement_params
    params.require(:installation).permit(
      classements_attributes: %i[id regime rubrique date_autorisation date_mise_en_service _destroy]
    )
  end
end
