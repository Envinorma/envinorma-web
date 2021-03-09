# frozen_string_literal: true

module ApplicationHelper
  def classement_infos(arrete, installation)
    arrete = Arrete.find(arrete.arrete_id) if arrete.is_a? EnrichedArrete

    classements = arrete.unique_classements.select do |classement|
      installation.classements.pluck(:rubrique, :regime).include?([classement.rubrique, classement.regime])
    end

    classements.map! do |classement|
      if classement.alinea.present?
        " - #{classement.rubrique} #{classement.regime} al. #{classement.alinea}"
      else
        " - #{classement.rubrique} #{classement.regime}"
      end
    end.join
  end

  def user_already_duplicated_installation?(user, installation)
    user.present? && user.installations.pluck(:duplicated_from_id).include?(installation.id)
  end

  def retrieve_duplicated_installation(user, installation)
    user.installations.where(duplicated_from_id: installation.id).first
  end

  HTML_ESCAPE = { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;' }.freeze

  def html_escape(txt)
    return '' unless txt

    txt.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
  end

  def odf_linebreak(txt)
    return '' unless txt

    txt.to_s.gsub("\n", '<text:line-break/>')
  end

  def sanitize(txt)
    txt = html_escape(txt)
    odf_linebreak(txt)
  end
end
