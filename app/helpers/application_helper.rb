module ApplicationHelper
  def classement_infos arrete, installation
    classement = Classement.where(arrete_id: arrete.id, installation_id: installation.id).first
    " - #{classement.rubrique} #{classement.regime}"
  end
end
