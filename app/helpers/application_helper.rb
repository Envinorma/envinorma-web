# frozen_string_literal: true

module ApplicationHelper
  def classement_infos(arrete, installation)
    arrete = Arrete.find(arrete.enriched_from_id) if arrete.enriched?

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

  def user_already_duplicated_installation?(user, installation)
    user.present? && user.installations.pluck(:duplicated_from_id).include?(installation.id)
  end

  def retrieve_duplicated_installation(user, installation)
    user.installations.where(duplicated_from_id: installation.id).first
  end
end
