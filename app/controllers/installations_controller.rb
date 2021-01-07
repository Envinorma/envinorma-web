class InstallationsController < ApplicationController
  RUBRIQUES = {
    "A": 0,
    "E": 1,
    "D": 2,
    "NC": 3,
    "empty": 4
  }

  include FilterArretes
  before_action :set_installation, except: [:index, :search]
  before_action :force_json, only: :search
  before_action :create_guest_if_needed, only: :duplicate_before_edit
  before_action :check_if_authorized_user, only: [:show, :edit]

  def index
    @installations = Installation.not_attached_to_user
  end

  def show
    @classements = @installation.classements.sort_by { |classement| classement.regime.present? ? RUBRIQUES[classement.regime.to_sym] : RUBRIQUES[:empty]}
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

  def edit
  end

  def update
    if @installation.update(classement_params)
      @installation.classements.each do |classement|
        arretes = []
        ArretesClassement.where(classement_id: classement.id).delete_all
        arretes << Arrete.where("data -> 'classements' @> ?", [{ rubrique: "#{classement.rubrique}", regime: "#{classement.regime}" }].to_json)

        arretes.flatten.each do |arrete|
          ArretesClassement.create(arrete_id: arrete.id, classement_id: classement.id)
        end
      end

      flash[:notice] = "L'installation a bien été mise à jour"
      redirect_to installation_path(@installation)
    else
      flash[:alert] = "L'installation n'a pas été mise à jour"
      render :edit
    end
  end

  def duplicate_before_edit
    if @installation.user_id == session[:user_id]
      redirect_to edit_installation_path(@installation)
    else
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
        user_id: session[:user_id]
      )

      @installation.classements.each do |classement|
        Classement.create(
          rubrique: classement.rubrique,
          regime: classement.regime,
          alinea: classement.alinea,
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
    end
    # backup if save failed
  end

  def search
    q = params[:q].downcase
    @installations = Installation.where("name ILIKE ? or s3ic_id ILIKE ?", "%#{q}%", "%#{q}%").not_attached_to_user.limit(10)
  end


  private

  def create_guest_if_needed
    return if session[:user_id]
    @user = User.create
    session[:user_id] = @user.id
  end

  def check_if_authorized_user
    return if @installation.user_id.nil?
    return if @user.present? && @installation.user_id == @user.id
    flash[:alert] = "Désolé, vous n’êtes pas autorisé à accéder à cette page"
    redirect_to root_path
  end

  def set_installation
    @installation = Installation.find(params[:id])
  end

  def force_json
    request.format = :json
  end

  def classement_params
    params.require(:installation).permit(classements_attributes: [:id, :regime, :rubrique, :date_autorisation, :_destroy])
  end
end
