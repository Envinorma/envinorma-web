# frozen_string_literal: true

module ApplicationHelper
  def common_classements(am_classements, installation_classement)
    classements = am_classements.filter do |classement|
      installation_classement.pluck(:rubrique, :regime).include?([classement.rubrique, classement.regime])
    end

    classements.map! do |classement|
      if classement.alineas.empty?
        "#{classement.rubrique} #{classement.regime}"
      else
        alineas_string = classement.alineas.join(' ou ')
        "#{classement.rubrique} #{classement.regime} al. #{alineas_string}"
      end
    end.join(' - ')
  end

  def classement_infos(am, installation) # rubocop:disable Naming/MethodParameterName
    common_classements(am.classements_with_alineas, installation.classements)
  end

  def prescription_checked?(alinea_ids, alinea_id)
    alinea_ids.include?(alinea_id)
  end
end
