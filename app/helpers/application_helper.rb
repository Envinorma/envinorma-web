# frozen_string_literal: true

module ApplicationHelper
  def classement_infos(arrete, installation)
    arrete = Arrete.find(arrete.arrete_id) if arrete.is_a? EnrichedArrete

    classements = arrete.unique_classements.select do |classement|
      installation.classements.pluck(:rubrique, :regime).include?([classement.rubrique, classement.regime])
    end

    classements.map! do |classement|
      if classement.alinea.present?
        " - #{classement.rubrique} #{classement.regime} al. #{classement.alinea}"
      else
        " - #{classement.rubrique} #{classement.regime}"
      end
    end.join
  end
end
