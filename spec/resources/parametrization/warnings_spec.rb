# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Parametrization::Warnings
end

RSpec.describe Parametrization::Warnings do
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

  def build_inapplicability(condition, alineas)
    json = <<~JSON
      {
        "condition": null,
        "alineas": #{alineas}
      }
    JSON
    inapplicability = JSON.parse(json, object_class: OpenStruct)
    inapplicability.condition = condition
    inapplicability
  end

  describe 'inapplicability_warning' do
    it 'generates warning when condition is inapplicable' do
      inapplicability = build_inapplicability(condition_and, [1, 2, 3])
      expected = "Certains alinéas sont inapplicables car les conditions suivantes sont satisfaites :\n"\
                 "- la date de déclaration est antérieure au 01/01/2020.\n"\
                 "- le régime de classement est l'enregistrement.\n"\
                 '- la date de mise en service est comprise entre le 01/01/2020 et le 31/12/2020.'
      expect(inapplicability_warning(inapplicability)).to eq(expected)
    end
  end
end
