# frozen_string_literal: true

module Parametrization
  module Conditions
    def satisfied?(condition, parameters)
      case condition['type']
      when 'AND'
        conditions_satified?(condition['conditions'], parameters).all?
      when 'OR'
        conditions_satified?(condition['conditions'], parameters).any?
      when 'EQUAL'
        equal_condition_satisfied?(condition, parameters)
      when 'GREATER'
        greater_condition_satisfied?(condition, parameters)
      when 'LITTLER'
        littler_condition_satisfied?(condition, parameters)
      when 'RANGE'
        range_condition_satisfied?(condition, parameters)
      else
        raise "Unknown condition type: #{condition['type']}"
      end
    end

    def potentially_satisfied?(condition, parameters)
      # a condition is potentially satisfied if the value of a parameter is unknown
      # but if is was known, the condition could be satisfied
      case condition['type']
      when 'AND', 'OR'
        children = condition['conditions'].map { |child| potentially_satisfied?(child, parameters) }
        condition['type'] == 'AND' ? children.all? : children.any?
      when 'EQUAL', 'GREATER', 'LITTLER', 'RANGE'
        return satisfied?(condition, parameters) if parameters.key?(condition['parameter']['id'])

        true
      else
        raise "Unknown condition type: #{condition['type']}"
      end
    end

    private

    def conditions_satified?(conditions, parameters)
      conditions.map { |condition| satisfied?(condition, parameters) }
    end

    def equal_condition_satisfied?(condition, parameters)
      return false unless parameters.key?(condition['parameter']['id'])

      parameters[condition['parameter']['id']] == parse_parameter(condition['target'], condition['parameter']['type'])
    end

    def greater_condition_satisfied?(condition, parameters)
      return false unless parameters.key?(condition['parameter']['id'])

      value = parameters[condition['parameter']['id']]
      target = parse_parameter(condition['target'], condition['parameter']['type'])
      condition['strict'] ? value > target : value >= target
    end

    def littler_condition_satisfied?(condition, parameters)
      return false unless parameters.key?(condition['parameter']['id'])

      value = parameters[condition['parameter']['id']]
      target = parse_parameter(condition['target'], condition['parameter']['type'])
      condition['strict'] ? value < target : value <= target
    end

    def range_condition_satisfied?(condition, parameters)
      return false unless parameters.key?(condition['parameter']['id'])

      value = parameters[condition['parameter']['id']]
      left_target = parse_parameter(condition['left'], condition['parameter']['type'])
      left_sat = condition['left_strict'] ? value > left_target : value >= left_target
      right_target = parse_parameter(condition['right'], condition['parameter']['type'])
      right_sat = condition['right_strict'] ? value < right_target : value <= right_target
      left_sat && right_sat
    end

    def parse_parameter(parameter_value, parameter_type)
      case parameter_type
      when 'DATE'
        parameter_value.to_date
      else
        parameter_value
      end
    end
  end
end
