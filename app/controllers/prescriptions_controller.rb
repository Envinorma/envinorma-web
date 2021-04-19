# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  def add_prescription
    puts ''
    puts 'ADD'
    puts params
    puts ''

    prescription = Prescription.where(alinea_id: params['id'], user_id: params['userId']).first
    puts prescription
    if prescription.nil?
      prescription = Prescription.new(
        reference: params['reference'],
        content: params['content'],
        alinea_id: params['id'],
        from_am_id: params['amId'],
        user_id: params['userId']
      )
      saved = prescription.save
      puts "Saved ? #{saved}"
    end

    respond_to do |format|
      format.json { render json: @params, status: :created }
    end
  end

  def remove_prescription
    puts ''
    puts 'REMOVE'
    puts params
    puts ''
    prescription = Prescription.where(alinea_id: params['id'], user_id: params['userId']).first
    Prescription.delete(prescription.id) unless prescription.nil?
    respond_to do |format|
      format.json { render json: @params }
    end
  end
end
