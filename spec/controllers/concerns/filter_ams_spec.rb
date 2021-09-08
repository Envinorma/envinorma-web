# frozen_string_literal: true

require 'rails_helper'
require './app/controllers/concerns/filter_ams'

RSpec.configure do |c|
  c.include FilterAMs
end

RSpec.describe FilterAMs do # rubocop:disable RSpec/FilePath
  let(:am) do
    am_json = <<~JSON
      {
        "id": "1",
        "applicability": {
          "condition_of_inapplicability": null,
          "applicable": true
        }
      }
    JSON
    JSON.parse(am_json, object_class: OpenStruct)
  end
  let(:classement_al1) { Classement.new(rubrique: '1234', regime: 'D', alinea: '1') }
  let(:classement_al11) { Classement.new(rubrique: '1234', regime: 'D', alinea: '11') }
  let(:classement_al_a) { Classement.new(rubrique: '1234', regime: 'D', alinea: 'a') }
  let(:classement_enregistrement) { Classement.new(rubrique: '1234', regime: 'E', alinea: '1') }

  describe 'date_match?' do
    it 'returns true and no warning if several classements are matching.' do
      expect(date_match?(am, [])).to eq [true, nil]
    end

    it 'returns true and no warning if condition is null.' do
      expect(date_match?(am, [Classement.new(rubrique: '1510', regime: 'A')])).to eq [true, nil]
    end
  end

  describe 'alineas_match?' do
    it 'returns false if no classement are given' do
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [])).to eq false
    end

    it 'returns true if one classement with matching alinea is given' do
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [classement_al1])).to eq true
    end

    it 'returns false if all given classements do not match AM alinea' do
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [classement_al11, classement_al_a])).to eq false
    end

    it 'returns true if any given classements have matching alinea' do
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [classement_al1, classement_al_a])).to eq true
    end

    it 'returns true if given classement matches one of the AM alineas' do
      am = FactoryBot.create(:am, :fake_am1)
      classements_with_alineas = [{ rubrique: '1234', regime: 'D', alineas: %w[1 2] }]
      am.update!(classements_with_alineas: classements_with_alineas)
      expect(alineas_match?(FactoryBot.create(:am, :fake_am1), [classement_al1])).to eq true
    end

    it 'returns true if am classement does not depend on alinea' do
      am = FactoryBot.create(:am, :fake_am1)
      classements_with_alineas = [{ rubrique: '1234', regime: 'E', alineas: [] }]
      am.update!(classements_with_alineas: classements_with_alineas)
      expect(alineas_match?(am, [classement_enregistrement])).to eq true
    end

    it 'returns true if any given classements have matching alinea and AM has several classements' do
      am = FactoryBot.create(:am, :fake_am1)
      classements_with_alineas = [{ rubrique: '1234', regime: 'D', alineas: ['1'] },
                                  { rubrique: '1234', regime: 'E', alineas: [] }]
      am.update!(classements_with_alineas: classements_with_alineas)

      expect(alineas_match?(am, [classement_enregistrement, classement_al_a])).to eq true
    end
  end

  describe 'sort_ams' do
    it 'returns sorted AMs by applicability and associated highest classement regime' do
      am_not_applicable = am.dup
      am_not_applicable.id = '2'
      am_not_applicable.applicability.applicable = false
      am_dup = am.dup
      am_dup.id = '3'
      ams = [am, am_not_applicable, am_dup]
      classements = { '1' => [classement_al1, classement_al11],
                      '2' => [classement_al_a],
                      '3' => [classement_enregistrement, classement_al1] }
      sorted_ams = sort_ams(ams, classements)
      expect(sorted_ams.map(&:id)).to eq %w[3 1 2]
    end
  end
end
