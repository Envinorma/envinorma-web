# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlineaManager do
  context 'when #recreate' do
    it 'creates alinea store with one alinea' do # rubocop:disable RSpec/MultipleExpectations
      FactoryBot.create(:am, :fake_am2)
      expect do
        described_class.recreate
      end.to change(AlineaStore, :count).from(0).to(1)

      expect(AlineaStore.first.section_reference).to eq('Article 1')
    end

    it 'creates alinea store with 3 nested alineas' do # rubocop:disable RSpec/MultipleExpectations
      FactoryBot.create(:am, :with_nested_sections)
      expect do
        described_class.recreate
      end.to change(AlineaStore, :count).from(0).to(3)

      expect(AlineaStore.pluck(:topic)).to eq(%w[AUCUN DISPOSITIONS_GENERALES DISPOSITIONS_GENERALES])
      expect(AlineaStore.pluck(:section_rank)).to eq(%w[0 0.0 0.0.0])
      expect(AlineaStore.pluck(:index_in_section)).to eq([0, 0, 0])
    end
  end
end
