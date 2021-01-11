module ApplicationHelper
  def classement_infos arrete, installation
    if arrete.is_a? EnrichedArrete
      arrete = Arrete.find(arrete.arrete_id)
    end
    classement_ref = Classement.find (installation.classements.pluck(:id) & arrete.classements.pluck(:id)).first
    classement_from_arrete_data = arrete.data.classements.select {|classement| classement.rubrique.include? classement_ref.rubrique}.first
    if classement_from_arrete_data.alinea.present?
      " - #{classement_from_arrete_data.rubrique} #{classement_from_arrete_data.regime} al. #{classement_from_arrete_data.alinea}"
    else
      " - #{classement_from_arrete_data.rubrique} #{classement_from_arrete_data.regime}"
    end
  end
end
