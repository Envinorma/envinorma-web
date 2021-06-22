# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataManager do
  context 'when #seed_installations_and_associations' do
    it 'creates 3 installations, 21 classements and 5 AP from sample files.' do
      expect do
        described_class.seed_installations_and_associations(validate: true, use_sample: true)
      end.to change(
        Installation, :count
      ).from(0).to(3).and change(
        Classement, :count
      ).from(0).to(21).and change(
        AP, :count
      ).from(0).to(5)
    end
  end

  context 'when #recreate_or_validate_from_file' do
    it 'creates 3 installations in 2 batches when batch size is 2' do
      filename = Rails.root.join('db/seeds/installations_sample_rspec.csv')
      expect do
        described_class.recreate_or_validate_from_file(filename, Installation, 2, true, {})
        described_class.recreate_or_validate_from_file(filename, Installation, 2, false, {})
      end.to change(Installation, :count).from(0).to(3)
    end

    it 'creates 21 classements in 11 batches when batch size is 2' do
      filename = Rails.root.join('db/seeds/classements_sample_rspec.csv')
      installation = FactoryBot.create(:installation)
      expect do
        mapping = { '0065.18698' => installation.id }
        described_class.recreate_or_validate_from_file(filename, Classement, 2, true, mapping)
        described_class.recreate_or_validate_from_file(filename, Classement, 2, false, mapping)
      end.to change(Classement, :count).from(0).to(21)
    end

    it 'creates 5 aps in 1 batch when batch size is 10' do
      filename = Rails.root.join('db/seeds/aps_sample_rspec.csv')
      installation = FactoryBot.create(:installation)
      expect do
        mapping = { '0065.00005' => installation.id }
        described_class.recreate_or_validate_from_file(filename, AP, 10, true, mapping)
        described_class.recreate_or_validate_from_file(filename, AP, 10, false, mapping)
      end.to change(AP, :count).from(0).to(5)
    end
  end
end
