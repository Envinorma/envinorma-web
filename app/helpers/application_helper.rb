module ApplicationHelper
  def classement_infos arrete, installation
    # rubrique = (arrete.data.classements.pluck(:rubrique) & installation.classements.pluck(:rubrique)).join
    # regime = (arrete.data.classements.pluck(:regime) & installation.classements.pluck(:regime)).join

    rubrique = arrete.data.classements.last.rubrique
    regime = arrete.data.classements.last.regime
    " - #{rubrique} #{regime}"
  end
end
