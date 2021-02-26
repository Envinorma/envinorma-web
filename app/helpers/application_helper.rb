# frozen_string_literal: true

module ApplicationHelper
  def classement_infos(arrete, installation)
    arrete = Arrete.find(arrete.arrete_id) if arrete.is_a? EnrichedArrete

    classements = arrete.data.classements_with_alineas.select do |classement|
      installation.classements.pluck(:rubrique).include?(classement.rubrique)
    end

    classements.map! do |classement|
      if classement.alineas.present?
        " - #{classement.rubrique} #{classement.regime} al. #{classement.alineas.join(', ')}"
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
