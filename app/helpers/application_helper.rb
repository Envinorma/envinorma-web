module ApplicationHelper
  def classement_infos arrete, installation
    if arrete.is_a? EnrichedArrete
      arrete = Arrete.find(arrete.arrete_id)
    end
    classement = Classement.find (installation.classements.pluck(:id) & arrete.classements.pluck(:id)).first
    " - #{classement.rubrique} #{classement.regime}"
  end
end
