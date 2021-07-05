# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Arrete' do
  before do
    FactoryBot.create(:arrete, :classement_2521_E)
  end

  describe 'topics_by_section' do
    it 'maps topic of parent to child section id' do
      expect(Arrete.first.topics_by_section['941cf0d1bA08']).to eq ['DISPOSITIONS_GENERALES']
    end

    it 'maps to no topic if no descendents have a topic' do
      expect(Arrete.first.topics_by_section['eB6CEdbaDCA3']).to eq ['AUCUN']
    end
  end
end
