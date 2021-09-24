# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AM' do
  before do
    FactoryBot.create(:am, :classement_2521_E)
    new_classements_with_alineas = [
      {
        alineas: %w[1 2],
        regime: 'E',
        rubrique: '2521'
      }
    ]
    AM.first.update!(classements_with_alineas: new_classements_with_alineas)
  end

  describe 'topics_by_section' do
    it 'maps topic of parent to child section id' do
      expect(AM.first.topics_by_section['941cf0d1bA08']).to eq ['DISPOSITIONS_GENERALES']
    end

    it 'maps to no topic if no descendents have a topic' do
      expect(AM.first.topics_by_section['eB6CEdbaDCA3']).to eq ['AUCUN']
    end
  end

  describe 'from_classements' do
    it 'maps no AM if no classements' do
      expect(AM.from_classements([], match_on_alineas: false)).to be_empty
    end

    it 'maps no AM if no matching classements' do
      classement = Classement.new(rubrique: '1510', regime: 'E')
      expect(AM.from_classements([classement], match_on_alineas: false)).to be_empty
    end

    it 'maps AM if matching classement even if not match on alinea' do
      classements = [Classement.new(rubrique: '2521', regime: 'E', alinea: '3')]
      expected = {}
      expected[AM.first.id] = classements
      expect(AM.from_classements(classements, match_on_alineas: false)).to eq expected
    end

    it 'maps no AM if classement matches only on rubrique and regime and match_on_alineas is true' do
      classement = Classement.new(rubrique: '2521', regime: 'E', alinea: '3')
      expect(AM.from_classements([classement], match_on_alineas: true)).to be_empty
    end

    it 'maps AM if classement matches also on alinea and match_on_alineas is true' do
      classements = [Classement.new(rubrique: '2521', regime: 'E', alinea: '2')]
      expected = {}
      expected[AM.first.id] = classements
      expect(AM.from_classements(classements, match_on_alineas: true)).to eq expected
    end

    it 'maps AM to both classements if bot matches' do
      classements = [
        Classement.new(rubrique: '2521', regime: 'E', alinea: '1'),
        Classement.new(rubrique: '2521', regime: 'E', alinea: '2')
      ]
      expected = {}
      expected[AM.first.id] = classements
      expect(AM.from_classements(classements, match_on_alineas: true)).to eq expected
    end
  end
end
