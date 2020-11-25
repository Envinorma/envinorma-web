module ApplicationHelper
  def classement_infos arrete, installation
    rubrique = (arrete.data.classements.pluck(:rubrique) & installation.classements.pluck(:rubrique)).join
    regime = (arrete.data.classements.pluck(:regime) & installation.classements.pluck(:regime)).join
    " - #{rubrique} #{regime}"
  end
end
