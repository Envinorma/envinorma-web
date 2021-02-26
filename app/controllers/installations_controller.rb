# frozen_string_literal: true

class InstallationsController < ApplicationController
  RUBRIQUES = {
    A: 0,
    E: 1,
    D: 2,
    NC: 3,
    empty: 4
  }.freeze

  include FilterArretes
  before_action :set_installation, except: %i[index search]
  before_action :force_json, only: :search
  before_action :create_guest_if_needed, only: :edit
  before_action :check_if_authorized_user, only: %i[show edit update]

  def index
    @installations = Installation.not_attached_to_user
  end

  def show
    set_aps

    @classements = @installation.classements.sort_by do |classement|
      classement.regime.present? ? RUBRIQUES[classement.regime.to_sym] : RUBRIQUES[:empty]
    end
    @arretes_list = @classements.map(&:arretes).flatten
    @arretes = []
    @arretes_list.uniq.each do |arrete|
      @arretes << if arrete.enriched_arretes.any?
                    filter_arretes(arrete, arrete.enriched_arretes).first
                  else
                    arrete
                  end
    end
  end

  def edit
    return if @installation.user_id == @user.id

    if helpers.user_already_duplicated_installation?(@user, @installation)
      redirect_to edit_installation_path(helpers.retrieve_duplicated_installation(@user, @installation))
    else
      duplicate_before_edit
    end
  end

  def update
    if @installation.update(classement_params)
      @installation.classements.each do |classement|
        ArretesClassement.update_for(classement)
      end

      flash[:notice] = "L'installation a bien été mise à jour"
      redirect_to installation_path(@installation)
    else
      flash[:alert] = "L'installation n'a pas été mise à jour"
      render :edit
    end
  end

  def duplicate_before_edit
    installation_duplicated = Installation.create(
      name: @installation.name,
      s3ic_id: @installation.s3ic_id,
      region: @installation.region,
      department: @installation.department,
      zipcode: @installation.zipcode,
      city: @installation.city,
      last_inspection: @installation.last_inspection,
      regime: @installation.regime,
      seveso: @installation.seveso,
      state: @installation.state,
      user_id: session[:user_id],
      duplicated_from_id: @installation.id
    )

    @installation.classements.each do |classement|
      Classement.create(
        rubrique: classement.rubrique,
        regime: classement.regime,
        alinea: classement.alinea,
        rubrique_acte: classement.rubrique_acte,
        regime_acte: classement.regime_acte,
        alinea_acte: classement.alinea_acte,
        activite: classement.activite,
        date_autorisation: classement.date_autorisation,
        volume: classement.volume,
        installation_id: installation_duplicated.id
      )
    end

    installation_duplicated.classements.each do |classement|
      arretes = Classement.find_by(rubrique: classement.rubrique, regime: classement.regime).arretes
      arretes.each do |arrete|
        ArretesClassement.create(arrete_id: arrete.id, classement_id: classement.id)
      end
    end

    redirect_to edit_installation_path(installation_duplicated)
    # backup if save failed
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

  def force_json
    request.format = :json
  end

  def classement_params
    params.require(:installation).permit(classements_attributes: %i[id regime rubrique date_autorisation
                                                                    _destroy])
  end
end
