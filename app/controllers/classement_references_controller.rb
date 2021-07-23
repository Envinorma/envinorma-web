# frozen_string_literal: true

class ClassementReferencesController < ApplicationController
  def search
    query = build_query(params[:q])
    # We choose 15 results because all rubrique except 1978 are present less than 15 times
    @classement_references = ClassementReference.where(query).limit(15)
  end

  private

  def build_query(user_input)
    query = "description ILIKE ? or concat(rubrique, ' ', regime, ' ', alinea) ILIKE ?"
    [query] + Array.new(2, "%#{user_input}%")
  end
end
