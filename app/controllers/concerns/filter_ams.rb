# frozen_string_literal: true

module FilterAMs
  extend ActiveSupport::Concern
  include Parametrization::Parameters

  def compute_applicable_ams_list(classements)
    classements_by_am_cid = AM.from_classements(classements)
    ams = AM.where(cid: classements_by_am_cid.keys.uniq)
    sort_ams(add_applicabilities(ams, classements_by_am_cid))
  end

  private

  def sort_ams(ams)
    ams.sort_by { |am| [am.data.applicability.applicable ? 0 : 1, am.rank_score] }
  end

  ALINEA_WARNING = "Les alinéas auxquels cet arrêté s'applique semblent ne pas correspondre "\
                   'aux alinéas de classements de cette installation.'

  def add_applicabilities(ams, classements_by_am_cid)
    ams.map { |am| add_applicability(am, classements_by_am_cid[am.cid]) }
  end

  def add_applicability(am, classements) # rubocop:disable Naming/MethodParameterName
    # TODO: re comment this
    alinea_match = alineas_match?(am, classements)
    date_match = date_match?(am, classements)
    applicable = (date_match && alinea_match)
    am.data.applicability.warnings.append(ALINEA_WARNING) unless alinea_match
    am.data.applicability.applicable = applicable
    am
  end

  def date_match?(am, classements) # rubocop:disable Naming/MethodParameterName
    return true if am.data.applicability.conditions_of_inapplicability.empty?

    inapplicable_for_classements = classements.map do |classement|
      parameters = parameter_dict(classement)
      am.data.applicability.conditions_of_inapplicability.map do |condition|
        satisfied?(condition, parameters)
      end.any?
    end
    inapplicable_for_classements.none?
  end

  def alineas_match?(am, installation_classements) # rubocop:disable Naming/MethodParameterName
    # Computes whether at least one classement alinea of the installation matches the alinea defined in
    # the AM classements
    alineas_by_rubrique_regime = am.classements_with_alineas.map do |classement|
      [[classement['rubrique'], classement['regime']], classement['alineas']]
    end.to_h
    matches = installation_classements.map do |classement|
      am_alineas = alineas_by_rubrique_regime[[classement.rubrique, classement.regime]]
      am_alineas.empty? ? true : am_alineas.include?(classement.alinea)
    end
    matches.any?
  end
end
