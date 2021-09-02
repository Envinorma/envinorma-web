# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Parametrization::Conditions
end

RSpec.describe Parametrization::Conditions do
  let(:condition_less_than) do
    json = <<~JSON
      {
        "type": "LITTLER",
        "parameter": {
          "id": "date-d-declaration",
          "type": "DATE"
        },
        "target": "2020-01-01",
        "strict": true
      }
    JSON
    JSON.parse(json, object_class: OpenStruct)
  end

  let(:condition_regime) do
    json = <<~JSON
      {
        "type": "EQUAL",
        "parameter": {
          "id": "regime",
          "type": "REGIME"
        },
        "target": "E"
      }
    JSON
    JSON.parse(json, object_class: OpenStruct)
  end

  let(:condition_range) do
    json = <<~JSON
      {
        "type": "RANGE",
        "parameter": {
          "id": "date-d-installation",
          "type": "DATE"
        },
        "left": "2020-01-01",
        "right": "2020-12-31",
        "left_strict": false,
        "right_strict": true
      }
    JSON
    JSON.parse(json, object_class: OpenStruct)
  end

  let(:condition_and) do
    json = <<~JSON
      {
        "type": "AND",
        "conditions": []
      }
    JSON
    condition = JSON.parse(json, object_class: OpenStruct)
    condition.conditions = [condition_less_than, condition_regime, condition_range]
    condition
  end

  let(:condition_or) do
    json = <<~JSON
      {
        "type": "OR",
        "conditions": []
      }
    JSON
    condition = JSON.parse(json, object_class: OpenStruct)
    condition.conditions = [condition_less_than, condition_regime, condition_range]
    condition
  end

  describe 'satisfied?' do
    it 'returns false if used parameters are unkown' do
      results = [condition_less_than, condition_regime, condition_range, condition_and, condition_or].map do |condition|
        satisfied?(condition, { alinea: '1' })
      end
      expect(results).to all(be false)
    end

    it 'returns true for less than condition if date is less than target' do
      expect(satisfied?(condition_less_than, { 'date-d-declaration' => '2000-01-01'.to_date })).to be true
    end

    it 'returns false for less than condition if date is more than target' do
      expect(satisfied?(condition_less_than, { 'date-d-declaration' => '2032-01-01'.to_date })).to be false
    end

    it 'returns true for equal condition if value is equal to target' do
      expect(satisfied?(condition_regime, { 'regime' => 'E' })).to be true
    end

    it 'returns false for equal condition if value is different from target' do
      expect(satisfied?(condition_regime, { 'regime' => 'A' })).to be false
    end

    it 'returns true for or condition if one condition is met' do
      expect(satisfied?(condition_or, { 'regime' => 'E' })).to be true
    end

    it 'returns false for or condition if no condition is met' do
      parameters = { 'regime' => 'A', 'date-d-declaration' => '2032-01-01'.to_date,
                     'date-d-installation' => '2000-01-01'.to_date }
      expect(satisfied?(condition_or, parameters)).to be false
    end

    it 'returns true for and condition if all conditions are met' do
      parameters = { 'regime' => 'E', 'date-d-declaration' => '2000-01-01'.to_date,
                     'date-d-installation' => '2020-05-01'.to_date }
      expect(satisfied?(condition_and, parameters)).to be true
    end

    it 'returns false for and condition if one condition is not met' do
      parameters = { 'regime' => 'E', 'date-d-declaration' => '2000-01-01'.to_date,
                     'date-d-installation' => '2000-01-01'.to_date }
      expect(satisfied?(condition_and, parameters)).to be false
    end
  end

  describe 'parse_parameter' do
    it 'returns parsed date if parameter_type is DATE' do
      expect(parse_parameter('2000-01-01', 'DATE')).to eq('2000-01-01'.to_date)
    end

    it 'returns unchanged value if parameter_type is not DATE' do
      expect(parse_parameter('E', 'REGIME')).to eq('E')
    end
  end

  describe 'potentially_satisfied?' do
    it 'returns true for all conditions if parameters are unknown' do
      results = [condition_less_than, condition_regime, condition_range, condition_and, condition_or].map do |condition|
        potentially_satisfied?(condition, { alinea: '1' })
      end
      expect(results).to all(be true)
    end

    it 'returns true for all conditions if conditions are satisfied' do
      parameters = { 'regime' => 'E', 'date-d-declaration' => '2000-01-01'.to_date,
                     'date-d-installation' => '2020-05-01'.to_date }
      results = [condition_less_than, condition_regime, condition_range, condition_and, condition_or].map do |condition|
        potentially_satisfied?(condition, parameters)
      end
      expect(results).to all(be true)
    end

    it 'returns true when condition is satisfied or parameter is unknown' do
      parameters = { 'regime' => 'D' }
      results = [condition_less_than, condition_regime, condition_range, condition_and, condition_or].map do |condition|
        potentially_satisfied?(condition, parameters)
      end
      expect(results).to eq [true, false, true, false, true]
    end
  end
end
