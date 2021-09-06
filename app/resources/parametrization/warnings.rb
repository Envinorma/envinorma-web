# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module Parametrization
  module Warnings
    include OpenStructHelper

    def inapplicability_warning(inapplicability)
      prefix = inapplicability['alineas'].blank? ? 'Cette section est inapplicable' : 'Certains alinéas sont inapplicables'
      "#{prefix} car #{human_condition(inapplicability['condition'])}."
    end

    def modification_warning(modification)
      "Cette section a été modifiée car #{human_condition(modification['condition'])}."
    end

    def potentially_satisfied_warning(condition, is_a_modification)
      adjective = is_a_modification ? 'modifiée' : 'inapplicable'
      "Cette section pourrait être #{adjective}. C'est le cas si #{human_condition(condition)}."
    end

    def inapplicable_arrete_warning(condition)
      "Cet arrêté ne s'applique pas à cette installation car #{human_condition(condition)}."
    end

    def potentially_inapplicable_arrete_warning(condition)
      "Cet arrêté pourrait ne pas être applicable. C'est le cas pour les installations "\
        "dont #{human_condition(condition)}."
    end

    private

    def human_condition(condition)
      case condition['type']
      when 'AND'
        and_human_condition(condition)
      when 'OR'
        or_human_condition(condition)
      when 'EQUAL'
        equal_human_condition(condition)
      when 'LITTLER'
        littler_human_condition(condition)
      when 'GREATER'
        greater_human_condition(condition)
      when 'RANGE'
        range_human_condition(condition)
      else
        raise "Unknown condition type #{condition['type']}"
      end
    end

    def and_human_condition(condition)
      child_conditions = condition['conditions'].map { |child| human_condition(child) }.sort
      [child_conditions[..-2].join(', '), child_conditions[-1]].join(' et ')
    end

    def or_human_condition(condition)
      child_conditions = condition['conditions'].map { |child| human_condition(child) }.sort
      [child_conditions[..-2].join(', '), child_conditions[-1]].join(' ou ')
    end

    def equal_human_condition(condition)
      return equal_regime_human_condition(condition['target']) if condition['parameter']['type'] == 'REGIME'

      "#{human_parameter(condition['parameter'])} est #{condition['target']}"
    end

    def equal_regime_human_condition(regime)
      "le régime de classement est #{human_regime(regime)}"
    end

    def human_regime(regime)
      case regime
      when 'A'
        "l'autorisation"
      when 'D'
        'la déclaration'
      when 'E'
        "l'enregistrement"
      else
        raise "Unknown regime #{regime}"
      end
    end

    def littler_human_condition(condition)
      case condition['parameter']['type']
      when 'DATE'
        "#{human_parameter(condition['parameter'])} est antérieure au #{human_date(condition['target'])}"
      when 'REAL_NUMBER'
        "#{human_parameter(condition['parameter'])} est inférieure à #{condition['target']}"
      else
        raise "Not implemented for parameter type #{condition['parameter']['type']}"
      end
    end

    def greater_human_condition(condition)
      case condition['parameter']['type']
      when 'DATE'
        "#{human_parameter(condition['parameter'])} est postérieure au #{human_date(condition['target'])}"
      when 'REAL_NUMBER'
        "#{human_parameter(condition['parameter'])} est supérieure à #{condition['target']}"
      else
        raise "Not implemented for parameter type #{condition['parameter']['type']}"
      end
    end

    def range_human_condition(condition)
      case condition['parameter']['type']
      when 'DATE'
        "#{human_parameter(condition['parameter'])} est comprise entre le #{human_date(condition['left'])} "\
        "et le #{human_date(condition['right'])}"
      when 'REAL_NUMBER'
        "#{human_parameter(condition['parameter'])} est supérieure à #{condition['left']} "\
        "et inférieure à #{condition['right']}"
      else
        raise "Not implemented for parameter type #{condition['parameter']['type']}"
      end
    end

    def human_date(date_string)
      date_string.to_date.strftime('%d/%m/%Y')
    end

    def human_parameter(parameter)
      return human_date_parameter(parameter['id']) if parameter['type'] == 'DATE'

      case parameter['id']
      when 'regime'
        'le régime'
      when 'rubrique'
        'la rubrique'
      when 'quantite-rubrique'
        'la quantité associée à la rubrique'
      when 'alinea'
        "l'alinea de classement"
      else
        raise "Unknown parameter #{parameter['id']}"
      end
    end

    def human_date_parameter(parameter_id)
      case parameter_id
      when 'date-d-autorisation', 'date-d-enregistrement'
        "la date d'#{parameter_id.split('-').last}"
      when 'date-d-declaration'
        'la date de déclaration'
      when 'date-d-installation'
        'la date de mise en service'
      else
        raise "Unknown parameter #{parameter_id}"
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
