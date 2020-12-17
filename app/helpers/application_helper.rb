module ApplicationHelper
  def classement_infos arrete, installation
    classement = Classement.find (installation.classements.pluck(:id) & arrete.classements.pluck(:id)).first
    " - #{classement.rubrique} #{classement.regime}"
  end
end
