# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  def index; end

  def create
    @prescription = Prescription.create(prescription_params)

    if @prescription.save
      flash[:notice] = 'Le prescription a été ajouté'
    else
      flash[:alert] = "Le prescription n'a pas été ajouté"
    end
  end

  def prescription_params
    params.require(:prescription).permit(:reference, :content, :user_id)
  end
end
