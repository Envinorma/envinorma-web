# frozen_string_literal: true

module Parametrization
  module Warnings
    include OpenStructHelper

    def inapplicability_warning(inapplicability)
      prefix = inapplicability.alineas.blank? ? 'Cette section est inapplicable' : 'Certains alinéas sont inapplicables'
      "#{prefix} car #{human_condition(inapplicability.condition)}"
    end

    def modification_warning(modification)
      "Ce paragraphe a été modifié car #{human_condition(modification.condition)}"
    end

    def potentially_satisfied_warning(condition, is_a_modification)
      adjective = is_a_modification ? 'modifié' : 'inapplicable'
      "Ce paragraphe pourrait être #{adjective} si #{human_condition(condition)}"
    end

    def human_condition(condition)
      case condition.type
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
        raise "Unknown condition type #{condition.type}"
      end
    end

    def and_human_condition(condition)
      child_conditions = condition.conditions.map { |child| human_condition(child) }
      separator = "\n- "
      "les conditions suivantes sont satisfaites : \n- #{child_conditions.join(separator)}"
    end

    def or_human_condition(condition)
      child_conditions = condition.conditions.map { |child| human_condition(child) }
      separator = "\n- "
      "au moins une des conditions suivantes est satisfaite : \n- #{child_conditions.join(separator)}"
    end

    def equal_human_condition(condition)
      return equal_regime_human_condition(condition.target) if condition.parameter.type == 'REGIME'

      "#{human_parameter(condition.parameter)} est #{condition.target}."
    end

    def equal_regime_human_condition(regime)
      "le régime de classement est #{human_regime(regime)}."
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
      case condition.parameter.type
      when 'DATE'
        "#{human_parameter(condition.parameter)} est antérieure au #{human_date(condition.target)}."
      when 'REAL_NUMBER'
        "#{human_parameter(condition.parameter)} est inférieure à #{condition.target}."
      else
        raise "Not implemented for parameter type #{condition.parameter.type}"
      end
    end

    def greater_human_condition(condition)
      case condition.parameter.type
      when 'DATE'
        "#{human_parameter(condition.parameter)} est postérieure au #{human_date(condition.target)}."
      when 'REAL_NUMBER'
        "#{human_parameter(condition.parameter)} est supérieure à #{condition.target}."
      else
        raise "Not implemented for parameter type #{condition.parameter.type}"
      end
    end

    def range_human_condition(condition)
      case condition.parameter.type
      when 'DATE'
        "#{human_parameter(condition.parameter)} est postérieure au #{human_date(condition.left)} "\
        "et antérieure au #{human_date(condition.right)}."
      when 'REAL_NUMBER'
        "#{human_parameter(condition.parameter)} est supérieure à #{condition.left} "\
        "et inférieure à #{condition.right}."
      else
        raise "Not implemented for parameter type #{condition.parameter.type}"
      end
    end

    def human_date(date_string)
      date_string.to_date.strftime('%d/%m/%Y')
    end

    def human_parameter(parameter)
      case parameter.id
      when 'date-d-autorisation', 'date-d-enregistrement'
        "la date d'#{parameter.id.split('-').last}"
      when 'date-d-declaration'
        'la date de déclaration'
      when 'date-d-installation'
        'la date de mise en service'
      when 'regime'
        'le régime'
      when 'rubrique'
        'la rubrique'
      when 'quantite-rubrique'
        'la quantité associée à la rubrique'
      when 'alinea'
        "l'alinea de classement"
      else
        raise "Unknown parameter #{parameter.id}"
      end
    end
  end
end