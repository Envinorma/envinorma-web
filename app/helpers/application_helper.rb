# frozen_string_literal: true

module ApplicationHelper
  def classement_infos(arrete, installation)
    arrete = Arrete.find(arrete.enriched_from_id) if arrete.enriched?

    classements = arrete.unique_classements.select do |classement|
      installation.classements.pluck(:rubrique, :regime).include?([classement.rubrique, classement.regime])
    end

    classements.map! do |classement|
      if classement.alinea.present?
        "#{classement.rubrique} #{classement.regime} al. #{classement.alinea}"
      else
        "#{classement.rubrique} #{classement.regime}"
      end
    end.join(' - ')
  end

  def prescription_checked?(alinea_ids, alinea_id)
    alinea_ids.include?(alinea_id)
  end
end
