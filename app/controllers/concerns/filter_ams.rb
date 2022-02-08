# frozen_string_literal: true

module FilterAMs
  extend ActiveSupport::Concern
  include Parametrization::Parameters

  def compute_applicable_ams_list(classements)
    classements_by_am_id = AM.from_classements(classements, match_on_alineas: false)
    ams = AM.find(classements_by_am_id.keys.uniq)
    am_with_applicabilities = add_applicabilities(ams, classements_by_am_id)
    sort_ams(am_with_applicabilities, classements_by_am_id)
  end

  private

  def sort_ams(ams, classements_by_am_id)
    # Sort AMs by applicability. Among AMs with the same applicability, sort by
    # the highest regime of the associated classements.
    ams.sort_by { |am| [am.applicability.applicable ? 0 : 1, highest_regime(classements_by_am_id[am.id])] }
  end

  def highest_regime(classements)
    classements.map(&:regime_score).min
  end

  ALINEA_WARNING = "Les alinéas auxquels cet arrêté s'applique semblent ne pas correspondre "\
                   'aux alinéas de classements de cette installation.'

  def add_applicabilities(ams, classements_by_am_id)
    ams.map { |am| add_applicability(am, classements_by_am_id[am.id]) }
  end

  def add_applicability(am, classements) # rubocop:disable Naming/MethodParameterName
    # Adds applicability information to the AM.
    # applicability.applicable is true if there is a match on alineas and on other criteria (dates, volume).
    # applicability.warnings is the concatenation of:
    # - the warning message if the alineas don't match
    # - the warning message if the other criteria don't match
    # - the default warning messages that are always displayed for some AM
    alinea_match = alineas_match?(am, classements)
    other_criteria_match, other_criteria_warning = other_criteria_match?(am, classements)
    applicable = (other_criteria_match && alinea_match)
    new_warnings = [other_criteria_warning, alinea_match ? nil : ALINEA_WARNING].compact
    am.applicability.warnings.concat(new_warnings)
    am.applicability.applicable = applicable
    am
  end

  def other_criteria_match?(am, classements) # rubocop:disable Naming/MethodParameterName
    # Computes where the AM condition of applicability is met. (Most of the time,
    # it is a condition on the dates, because ALINEA, RUBRIQUE and REGIME are
    # handled in classement_with_alineas).
    # Returns a pair [other_criteria_match, other_criteria_warning]
    # other_criteria_match is true if the condition of inapplicability is not met
    # other_criteria_warning is defined if other_criteria_match is false and if the condition of
    # inapplicability could be met.
    condition = am.applicability.condition_of_inapplicability

    return [true, nil] if condition.nil? # always applicable

    classements_parameters = classements_parameter_hash(classements)

    applicable, warning = if satisfied?(condition, classements_parameters)
                            [false, inapplicable_arrete_warning(condition)]
                          elsif potentially_satisfied?(condition, classements_parameters)
                            [true, potentially_inapplicable_arrete_warning(condition)]
                          else
                            [true, nil]
                          end
    [applicable, warning]
  end

  def alineas_match?(am, installation_classements) # rubocop:disable Naming/MethodParameterName
    # Computes whether at least one classement alinea of the installation matches the alinea defined in
    # the AM classements
    alineas_by_rubrique_regime = am.classements_with_alineas.to_h do |classement|
      [[classement['rubrique'], classement['regime']], classement['alineas']]
    end
    matches = installation_classements.map do |classement|
      am_alineas = alineas_by_rubrique_regime[[classement.rubrique, classement.regime]]
      am_alineas.empty? ? true : am_alineas.include?(classement.alinea)
    end
    matches.any?
  end
end
