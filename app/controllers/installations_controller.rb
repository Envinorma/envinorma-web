# frozen_string_literal: true

class InstallationsController < ApplicationController
  REGIMES = {
    A: 0,
    E: 1,
    D: 2,
    NC: 3,
    unknown: 4,
    empty: 5
  }.freeze

  include FilterArretes
  before_action :set_installation, except: %i[index search]
  before_action :force_json, only: :search
  before_action :check_if_authorized_user, only: %i[show edit update]

  def index
    @installations = Installation.not_attached_to_user
  end

  def show
    set_aps

    @classements = @installation.classements.sort_by do |classement|
      classement.regime.present? ? REGIMES[classement.regime.to_sym] : REGIMES[:empty]
    end

    arretes_list = get_unique_classements_from(@classements).map(&:arretes).flatten

    @arretes = []
    arretes_list.uniq.each do |arrete|
      @arretes << if arrete.enriched_arretes.any?
                    filter_arretes(arrete, arrete.enriched_arretes).first
                  else
                    arrete
                  end
    end
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
    q = params[:q].downcase
    @installations = Installation.where('name ILIKE ? or s3ic_id ILIKE ?', "%#{q}%",
                                        "%#{q}%").not_attached_to_user.limit(10)
  end

  private

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def set_aps
    @aps = if @installation.duplicated_from_id?
             Installation.find(@installation.duplicated_from_id).APs
           else
             @installation.APs
           end
  end

  def get_unique_classements_from(classements)
    unique_classements = []
    classements.each do |classement|
      unique_classements << UniqueClassement.where(rubrique: classement.rubrique, regime: classement.regime).to_a
    end
    unique_classements.flatten
  end

  def force_json
    request.format = :json
  end

  def classement_params
    params.require(:installation).permit(classements_attributes: %i[id regime rubrique date_autorisation
                                                                    _destroy])
  end
end
