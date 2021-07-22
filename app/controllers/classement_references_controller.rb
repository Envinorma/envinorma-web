# frozen_string_literal: true

class ClassementReferencesController < ApplicationController
  def search
    args = build_query(params[:q])
    @classement_references = ClassementReference.where(args).limit(10)
  end

  private

  def build_query(user_input)
    query = 'description ILIKE ? or rubrique ILIKE ?'
    [query] + Array.new(2, "%#{user_input}%")
  end
end
