module ApplicationHelper
  def classement_infos arrete, installation
    classement = arrete.classements.find_by(installation_id = @installation_id)
    " - #{classement.rubrique} #{classement.regime}"
  end
end
