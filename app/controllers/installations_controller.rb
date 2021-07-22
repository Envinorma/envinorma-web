# frozen_string_literal: true

class InstallationsController < ApplicationController
  include FilterArretes
  include RegimeHelper
  before_action :force_json, only: :search
  before_action :set_installation, only: %i[show edit edit_name update destroy]
  before_action :user_can_modify_installation, only: %i[edit edit_name update destroy]
  before_action :user_can_visit_installation, only: %i[show]

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

  def edit; end

  def edit_name; end

  def create
    return create_from_existing_installation if params[:id].present?

    @installation = Installation.create(
      name: 'Mon installation',
      s3ic_id: '0000.00000',
      user_id: @user.id
    )

    redirect_to new_installation_classement_path(@installation)
  end

  def create_from_existing_installation
    set_installation
    installation_duplicated = @installation.duplicate!(@user)
    redirect_to installation_path(installation_duplicated)
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

  def destroy
    @installation.destroy
    if @user.installations.present?
      flash[:notice] = "L'installation a bien été supprimée"
      redirect_to user_path
    else
      flash[:notice] = "L'installation a bien été supprimée. Vous n'avez plus d'installation"
      redirect_to root_path
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
    params.require(:installation).permit(:name,
                                         classements_attributes: %i[id regime rubrique date_autorisation
                                                                    date_mise_en_service _destroy])
  end
end
