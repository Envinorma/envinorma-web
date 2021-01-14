module ApplicationHelper
  def classement_infos arrete, installation
    if arrete.is_a? EnrichedArrete
      arrete = Arrete.find(arrete.arrete_id)
    end
    classement_ref = Classement.find (installation.classements.pluck(:id) & arrete.classements.pluck(:id)).first
    classement_from_arrete_data = arrete.data.classements_with_alineas.select {|classement| classement.rubrique.include? classement_ref.rubrique}.first
    if classement_from_arrete_data.alineas.present?
      " - #{classement_from_arrete_data.rubrique} #{classement_from_arrete_data.regime} al. #{classement_from_arrete_data.alineas.join(', ')}"
    else
      " - #{classement_from_arrete_data.rubrique} #{classement_from_arrete_data.regime}"
    end
  end

  def user_already_duplicated_installation? user, installation
    user.present? && user.installations.pluck(:duplicated_from_id).include?(installation.id)
  end

  def retrieve_duplicated_installation user, installation
    user.installations.where(duplicated_from_id: installation.id).first
  end
end
