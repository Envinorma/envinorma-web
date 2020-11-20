module ApplicationHelper
  def transform_for_id string
    I18n.transliterate(string).delete ' '
  end

  def classement_infos arrete, installation
    rubrique = (arrete.data.classements.pluck(:rubrique) & installation.classements.pluck(:rubrique)).join
    regime = (arrete.data.classements.pluck(:regime) & installation.classements.pluck(:regime)).join
    " - #{rubrique} #{regime}"
  end
end
