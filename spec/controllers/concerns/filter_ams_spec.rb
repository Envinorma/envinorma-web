# frozen_string_literal: true

require 'rails_helper'
require './app/controllers/concerns/filter_ams'

RSpec.configure do |c|
  c.include FilterAMs
end

RSpec.describe FilterAMs do # rubocop:disable RSpec/FilePath
  context 'when :date_match?' do
    it 'returns true and no warning if several classements are matching.' do
      am_json = <<~JSON
        {
          "applicability": {
            "condition_of_inapplicability": null
          }
        }
      JSON
      am = JSON.parse(am_json, object_class: OpenStruct)
      expect(date_match?(am, [])).to eq [true, nil]
    end

    it 'returns true and no warning if condition is null.' do
      am_json = <<~JSON
        {
          "applicability": {
            "condition_of_inapplicability": null
          }
        }
      JSON
      am = JSON.parse(am_json, object_class: OpenStruct)
      expect(date_match?(am, [Classement.new(rubrique: '1510', regime: 'A')])).to eq [true, nil]
    end
  end

  context 'when :alineas_match?' do
    it 'returns false if no classement are given' do
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [])).to eq false
    end

    it 'returns true if one classement with matching alinea is given' do
      classement = Classement.new(rubrique: '1234', regime: 'D', alinea: '1')
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [classement])).to eq true
    end

    it 'returns false if all given classements do not match AM alinea' do
      classement1 = Classement.new(rubrique: '1234', regime: 'D', alinea: '11')
      classement2 = Classement.new(rubrique: '1234', regime: 'D', alinea: 'A')
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [classement1, classement2])).to eq false
    end

    it 'returns true if any given classements have matching alinea' do
      classement1 = Classement.new(rubrique: '1234', regime: 'D', alinea: '1')
      classement2 = Classement.new(rubrique: '1234', regime: 'D', alinea: 'A')
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [classement1, classement2])).to eq true
    end

    it 'returns true if given classement matches one of the AM alineas' do
      classement1 = Classement.new(rubrique: '1234', regime: 'D', alinea: '1')
      am = FactoryBot.create(:am, :fake_am1)
      classements_with_alineas = [{ rubrique: '1234', regime: 'D', alineas: %w[1 2] }]
      am.update!(classements_with_alineas: classements_with_alineas)
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [classement1])).to eq true
    end

    it 'returns true if am classement does not depend on alinea' do
      am = FactoryBot.create(:am, :fake_am1)
      classements_with_alineas = [{ rubrique: '1234', regime: 'E', alineas: [] }]
      am.update!(classements_with_alineas: classements_with_alineas)
      classement1 = Classement.new(rubrique: '1234', regime: 'E', alinea: '1')
      expect(alineas_match?(am, [classement1])).to eq true
    end

    it 'returns true if any given classements have matching alinea and AM has several classements' do
      am = FactoryBot.create(:am, :fake_am1)
      classements_with_alineas = [{ rubrique: '1234', regime: 'D', alineas: ['1'] },
                                  { rubrique: '1234', regime: 'E', alineas: [] }]
      am.update!(classements_with_alineas: classements_with_alineas)

      classement2 = Classement.new(rubrique: '1234', regime: 'D', alinea: 'A')
      classement1 = Classement.new(rubrique: '1234', regime: 'E', alinea: '1')
      expect(alineas_match?(am, [classement1, classement2])).to eq true
    end
  end
end
