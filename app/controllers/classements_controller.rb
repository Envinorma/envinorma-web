# frozen_string_literal: true

class ClassementsController < ApplicationController
  before_action :set_installation
  before_action :user_can_modify_installation, only: %i[new create]

  def new
    @classement = Classement.new
  end

  def create
    form_params = params[:classement]
    reference = ClassementReference.find(form_params[:reference_id])

    @classement = Classement.create_from(@installation.id, reference, form_params)

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
end
