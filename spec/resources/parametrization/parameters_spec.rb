# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Parametrization::Parameters
end

RSpec.describe Parametrization::Parameters do
  let(:section) do
    path = Rails.root.join('spec/fixtures/sections/section.json')
    JSON.parse(File.read(path), object_class: OpenStruct)
  end

  describe 'classements_parameter_dict' do
    it 'returns empty dict for no classements' do
      expect(classements_parameter_dict([])).to eq({})
    end

    it 'returns empty dict if several classements with different regime' do
      classements = [
        FactoryBot.create(:classement, :classement_2521_E, regime: 'E'),
        FactoryBot.create(:classement, :classement_2521_E, regime: 'A')
      ]
      expect(classements_parameter_dict(classements)).to eq({})
    end

    it 'returns dict with regime if several classements with same regime' do
      classements = [
        FactoryBot.create(:classement, :classement_2521_E, regime: 'E'),
        FactoryBot.create(:classement, :classement_2521_E, regime: 'E')
      ]
      expect(classements_parameter_dict(classements)).to eq({ 'regime' => 'E' })
    end
  end

  describe 'deactivate_alineas' do
    it 'deactivates all alineas if target_alineas is nil' do
      deactivate_alineas(section, nil)
      expect(section.outer_alineas.map(&:active)).to all(be(false))
    end

    it 'sets applicability.active to false if target_alineas is nil' do
      deactivate_alineas(section, nil)
      expect(section.applicability.active).to be(false)
    end

    it 'deactivates children alineas if target_alineas is nil' do
      deactivate_alineas(section, nil)
      children_alineas = section.sections.map(&:outer_alineas).flatten.map(&:active)
      expect(children_alineas).to all(be(false))
    end

    it 'deactivates only targeted alineas if target_alineas is not nil' do
      deactivate_alineas(section.sections[0], [1])
      expect(section.sections[0].outer_alineas.map(&:active)).to eq([true, false])
    end

    it 'sets applicability.active to true if target_alineas is not nil' do
      deactivate_alineas(section.sections[0], [1])
      expect(section.sections[0].applicability.active).to be(true)
    end

    it 'does not deactivate children alineas if target_alineas is not nil' do
      deactivate_alineas(section, [0])
      children_alineas = section.sections.map(&:outer_alineas).flatten.map(&:active)
      expect(children_alineas).to all(be(true))
    end
  end

  describe 'apply_parameter_to_section' do
    it 'concatenates all warnings if parameters are unknown' do
      apply_parameter_to_section(section, {})
      warnings = [
        'Cette section n\'est pas applicable si l\'exploitant n\'en fait pas la demande.',
        'Cette section pourrait être inapplicable. '\
        'C\'est le cas si la date d\'enregistrement est antérieure au 01/01/2020.',
        'Cette section pourrait être inapplicable. '\
        'C\'est le cas si la date de mise en service est antérieure au 02/01/2020.'
      ]
      expect(section.applicability.warnings).to eq(warnings)
    end

    it 'concatenates only warnings that could that could be satisfied if no condition is satisfied' do
      apply_parameter_to_section(section, { 'date-d-enregistrement' => '01/01/2021'.to_date })
      warnings = [
        'Cette section n\'est pas applicable si l\'exploitant n\'en fait pas la demande.',
        'Cette section pourrait être inapplicable. '\
        'C\'est le cas si la date de mise en service est antérieure au 02/01/2020.'
      ]
      expect(section.applicability.warnings).to eq(warnings)
    end

    it 'applies inapplicability if condition is satisfied' do
      parameters = { 'date-d-installation' => '01/01/2019'.to_date }
      apply_parameter_to_section(section, parameters)
      warnings = [
        'Cette section n\'est pas applicable si l\'exploitant n\'en fait pas la demande.',
        'Cette section est inapplicable car la date de mise en service est antérieure au 02/01/2020.'
      ]
      expect(section.applicability.warnings).to eq(warnings)
    end

    it 'deactivates all alineas if condition is satisfied' do
      parameters = { 'date-d-installation' => '01/01/2019'.to_date }
      apply_parameter_to_section(section, parameters)
      children_alineas = section.sections.map(&:outer_alineas).flatten.map(&:active)
      expect(children_alineas).to all(be(false))
    end

    it 'modifies only child section if its modification condition is satisfied' do
      parameters = { 'regime' => 'E' }
      apply_parameter_to_section(section, parameters)
      modified = [section.applicability.modified] + section.sections.map(&:applicability).map(&:modified)
      expect(modified).to eq([false, false, true])
    end

    it 'modifies child section storing its previous version it condition is satisfied' do
      parameters = { 'regime' => 'E' }
      apply_parameter_to_section(section, parameters)
      previous_version = section.sections[1].applicability.previous_version
      texts = [previous_version.title.text] + previous_version.outer_alineas.map(&:text)
      expected_texts = ['Article 2', 'Alinea 1 sous-section 2.', 'Alinea 2 sous-section 2.']
      expect(texts).to eq(expected_texts)
    end

    it 'does not apply child modification if parent inapplicability is satisfied' do
      parameters = { 'regime' => 'E', 'date-d-installation' => '01/01/2019'.to_date }
      apply_parameter_to_section(section, parameters)
      modified = [section.applicability.modified] + section.sections.map(&:applicability).map(&:modified)
      expect(modified).to eq([false, false, false])
    end
  end
end
