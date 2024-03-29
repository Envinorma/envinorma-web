# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module Parametrization
  module Warnings
    def inapplicability_warning(inapplicability)
      prefix = inapplicability.alineas.blank? ? 'Cette section est inapplicable' : 'Certains alinéas sont inapplicables'
      "#{prefix} car #{human_condition(inapplicability.condition)}."
    end

    def modification_warning(modification)
      "Cette section a été modifiée car #{human_condition(modification.condition)}."
    end

    def potentially_satisfied_warning(condition, is_a_modification, alineas = nil)
      first_sentence = if is_a_modification
                         'Cette section pourrait être modifiée'
                       elsif alineas.blank?
                         'Cette section pourrait être inapplicable'
                       else
                         potentially_inapplicable_alineas_sentence(alineas)
                       end
      "#{first_sentence}. C'est le cas si #{human_condition(condition)}."
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
      humanize_and_aggregate(condition.conditions, ' et ')
    end

    def or_human_condition(condition)
      humanize_and_aggregate(condition.conditions, ' ou ')
    end

    def humanize_and_aggregate(conditions, separator)
      return humanize_similar_equal_conditions(conditions, separator) if similar_equal_conditions?(conditions)

      child_conditions = conditions.map { |child| human_condition(child) }.sort
      join_with_comma_and_separator(child_conditions, separator)
    end

    def similar_equal_conditions?(conditions)
      return false unless conditions.all? { |child| child.type == 'EQUAL' }

      conditions.map(&:parameter).map(&:id).uniq.size == 1
    end

    def humanize_similar_equal_conditions(conditions, separator)
      parameter = conditions.first.parameter
      targets = conditions.map(&:target).map { |target| human_parameter_value(parameter.id, target) }.sort
      "#{human_parameter(parameter)} est #{join_with_comma_and_separator(targets, separator)}"
    end

    def join_with_comma_and_separator(strings, separator)
      return strings.first if strings.length == 1

      [strings[..-2].join(', '), strings[-1]].join(separator)
    end

    def equal_human_condition(condition)
      "#{human_parameter(condition.parameter)} est #{human_parameter_value(condition.parameter.id, condition.target)}"
    end

    def human_parameter_value(parameter_id, value)
      return human_regime(value) if parameter_id == 'regime'

      value
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
        "#{human_parameter(condition.parameter)} est antérieure au #{human_date(condition.target)}"
      when 'REAL_NUMBER'
        "#{human_parameter(condition.parameter)} est inférieure à #{condition.target}"
      else
        raise "Not implemented for parameter type #{condition.parameter.type}"
      end
    end

    def greater_human_condition(condition)
      case condition.parameter.type
      when 'DATE'
        "#{human_parameter(condition.parameter)} est postérieure au #{human_date(condition.target)}"
      when 'REAL_NUMBER'
        "#{human_parameter(condition.parameter)} est supérieure à #{condition.target}"
      else
        raise "Not implemented for parameter type #{condition.parameter.type}"
      end
    end

    def range_human_condition(condition)
      case condition.parameter.type
      when 'DATE'
        "#{human_parameter(condition.parameter)} est comprise entre le #{human_date(condition.left)} "\
        "et le #{human_date(condition.right)}"
      when 'REAL_NUMBER'
        "#{human_parameter(condition.parameter)} est supérieure à #{condition.left} "\
        "et inférieure à #{condition.right}"
      else
        raise "Not implemented for parameter type #{condition.parameter.type}"
      end
    end

    def human_date(date_string)
      date_string.to_date.strftime('%d/%m/%Y')
    end

    def human_parameter(parameter)
      return human_date_parameter(parameter.id) if parameter.type == 'DATE'

      case parameter.id
      when 'regime'
        'le régime de classement'
      when 'rubrique'
        'la rubrique'
      when 'quantite-rubrique'
        'la quantité associée à la rubrique'
      when 'alinea'
        "l'alinéa de classement"
      else
        raise "Unknown parameter #{parameter.id}"
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

    def potentially_inapplicable_alineas_sentence(alineas)
      raise ArgumentError, 'No alineas' if alineas.empty?

      alineas = alineas.map { |alinea| alinea + 1 }.sort # For human readability

      return "L'alinéa #{alineas[0]} pourrait être inapplicable" if alineas.size == 1

      if range_of_size_three_at_least?(alineas)
        return "Les alinéas #{alineas.min} à #{alineas.max} pourraient être inapplicables"
      end

      "Les alinéas #{join_with_comma_and_separator(alineas, ' et ')} pourraient être inapplicables"
    end

    def range_of_size_three_at_least?(alineas)
      alineas.size >= 3 && alineas.length == alineas.uniq.max - alineas.min + 1
    end
  end
end
# rubocop:enable Metrics/ModuleLength
