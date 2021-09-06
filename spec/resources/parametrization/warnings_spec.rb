# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Parametrization::Warnings
end

RSpec.describe Parametrization::Warnings do
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

  def equal_condition(type, id, target)
    json = <<~JSON
      {
        "type": "EQUAL",
        "parameter": {
          "id": "#{id}",
          "type": "#{type}"
        },
        "target": "#{target}"
      }
    JSON
    JSON.parse(json, object_class: OpenStruct)
  end

  def merge_conditions(type, conditions)
    json = <<~JSON
      {
        "type": "#{type}",
        "conditions": []
      }
    JSON
    condition = JSON.parse(json, object_class: OpenStruct)
    condition.conditions = conditions
    condition
  end

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

  let(:regime_enregistrement) do
    equal_condition('REGIME', 'regime', 'E')
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
    merge_conditions('AND', [condition_less_than, regime_enregistrement, condition_range])
  end

  let(:condition_or) do
    merge_conditions('OR', [condition_less_than, regime_enregistrement, condition_range])
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

  describe 'modification_warning' do
    it 'generates modification warning with equal target' do
      modification = build_modification(regime_enregistrement)
      expected = 'Cette section a été modifiée car '\
                 "le régime de classement est l'enregistrement."
      expect(modification_warning(modification)).to eq(expected)
    end
  end

  describe 'potentially_satisfied_warning' do
    it 'generates potential modification warning with equal target' do
      expected = "Cette section pourrait être modifiée. C'est le cas si "\
                 "le régime de classement est l'enregistrement."
      expect(potentially_satisfied_warning(regime_enregistrement, true)).to eq(expected)
    end

    it 'generates potential inapplicability warning with equal target' do
      expected = "Cette section pourrait être inapplicable. C'est le cas si "\
                 "le régime de classement est l'enregistrement."
      expect(potentially_satisfied_warning(regime_enregistrement, false)).to eq(expected)
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
      expect(human_condition(regime_enregistrement)).to eq(expected)
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

  describe 'humanize_and_aggregate' do
    it 'generates warning from child only when there is only one child condition' do
      expected = 'la date de mise en service est comprise entre le 01/01/2020 et le 31/12/2020'
      expect(humanize_and_aggregate([condition_range], ' et ')).to eq(expected)
    end

    it 'generates warning with simplified targets if all conditions have the same type' do
      expected = 'l\'alinéa de classement est 1-a, 1-b ou 3'
      conditions = [equal_condition('ALINEA', 'alinea', '3'),
                    equal_condition('ALINEA', 'alinea', '1-b'),
                    equal_condition('ALINEA', 'alinea', '1-a')]
      expect(humanize_and_aggregate(conditions, ' ou ')).to eq(expected)
    end

    it 'generates warning without simplification if conditions are of different types' do
      expected = 'l\'alinéa de classement est 1-b, l\'alinéa de classement est 3 ou le régime'\
                 ' de classement est l\'enregistrement'
      condition = [equal_condition('ALINEA', 'alinea', '3'),
                   equal_condition('ALINEA', 'alinea', '1-b'),
                   regime_enregistrement]
      expect(humanize_and_aggregate(condition, ' ou ')).to eq(expected)
    end
  end

  describe 'join_with_comma_and_separator' do
    it 'does nothing if there is only one element' do
      expect(join_with_comma_and_separator(['this is a cat'], ' and ')).to eq('this is a cat')
    end

    it 'joins two elements with separator' do
      expected = 'this is a cat and this is a dog'
      expect(join_with_comma_and_separator(['this is a cat', 'this is a dog'], ' and ')).to eq(expected)
    end

    it 'joins three elements with comma and separator' do
      merged_sentence = join_with_comma_and_separator(['this is a cat', 'this is a dog', 'this is a mouse'], ' and ')
      expect(merged_sentence).to eq('this is a cat, this is a dog and this is a mouse')
    end
  end
end
