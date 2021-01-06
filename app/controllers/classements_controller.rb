class ClassementsController < ApplicationController
  before_action :set_installation

  def new
    @classement = Classement.new
  end

  def create
    @classement = Classement.create(classement_params)

    if @classement.save
      arretes = []
      arretes << Arrete.where("data -> 'classements' @> ?", [{ rubrique: "#{@classement.rubrique}", regime: "#{@classement.regime}" }].to_json)
      arretes.flatten.each do |arrete|
        ArretesClassement.create!(arrete_id: arrete.id, classement_id: @classement.id)
      end

      flash[:notice] = "Le classement a été ajouté"
      redirect_to installation_path(@installation)
    else
      flash[:alert] = "Le classement n'a pas été ajouté"
      render 'new'
    end
  end

  def destroy
  end

  private

  def set_installation
    @installation = Installation.find(params[:installation_id])
  end

  def classement_params
    params.require(:classement).permit(:rubrique, :regime, :date_autorisation, :installation_id)
  end
end
