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
      expected = 'Certains alinéas sont inapplicables car '\
                 'la date de déclaration est antérieure au 01/01/2020, '\
                 'la date de mise en service est comprise entre le 01/01/2020 et le 31/12/2020 et '\
                 'le régime de classement est l\'enregistrement.'
      expect(inapplicability_warning(inapplicability)).to eq(expected)
    end

    it 'generates warning for condition of type `less-than` when all section alineas are inapplicable' do
      inapplicability = build_inapplicability(condition_less_than, 'null')
      expected = 'Cette section est inapplicable car la date de déclaration est antérieure au 01/01/2020.'
      expect(inapplicability_warning(inapplicability)).to eq(expected)
    end
  end

  def build_modification(condition)
    json = <<~JSON
      {
        "condition": null,
        "new_version": {
          "title": {"text": "Nouveau titre"},
          "sections": [],
          "outer_alineas": []
        }
      }
    JSON
    modification = JSON.parse(json, object_class: OpenStruct)
    modification.condition = condition
    modification
  end

  describe 'modification_warning' do
    it 'generates modification warning with equal target' do
      modification = build_modification(condition_regime)
      expected = 'Ce paragraphe a été modifié car '\
                 "le régime de classement est l'enregistrement."
      expect(modification_warning(modification)).to eq(expected)
    end
  end

  describe 'potentially_satisfied_warning' do
    it 'generates potential modification warning with equal target' do
      expected = "Ce paragraphe pourrait être modifié. C'est le cas si "\
                 "le régime de classement est l'enregistrement."
      expect(potentially_satisfied_warning(condition_regime, true)).to eq(expected)
    end

    it 'generates potential inapplicability warning with equal target' do
      expected = "Ce paragraphe pourrait être inapplicable. C'est le cas si "\
                 "le régime de classement est l'enregistrement."
      expect(potentially_satisfied_warning(condition_regime, false)).to eq(expected)
    end
  end

  describe 'human_condition' do
    it 'generates human condition from range condition' do
      expected = 'la date de mise en service est comprise entre le 01/01/2020 et le 31/12/2020'
      expect(human_condition(condition_range)).to eq(expected)
    end

    it 'generates human condition from less-than condition' do
      expected = 'la date de déclaration est antérieure au 01/01/2020'
      expect(human_condition(condition_less_than)).to eq(expected)
    end

    it 'generates human condition from equal condition' do
      expected = 'le régime de classement est l\'enregistrement'
      expect(human_condition(condition_regime)).to eq(expected)
    end

    it 'generates human condition from and condition' do
      expected = 'la date de déclaration est antérieure au 01/01/2020, '\
                 'la date de mise en service est comprise entre le 01/01/2020 et le 31/12/2020 et '\
                 'le régime de classement est l\'enregistrement'
      expect(human_condition(condition_and)).to eq(expected)
    end

    it 'generates human condition from or condition' do
      expected = 'la date de déclaration est antérieure au 01/01/2020, '\
                 'la date de mise en service est comprise entre le 01/01/2020 et le 31/12/2020 ou '\
                 'le régime de classement est l\'enregistrement'
      expect(human_condition(condition_or)).to eq(expected)
    end
  end

  describe 'and_human_condition' do
    it 'generates warning from child only when there is only one child condition' do
      condition_and.dup.conditions = [condition_range]
      expected = 'la date de mise en service est comprise entre le 01/01/2020 et le 31/12/2020'
      expect(human_condition(condition_range)).to eq(expected)
    end
  end
end
