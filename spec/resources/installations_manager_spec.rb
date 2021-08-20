# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstallationsManager do
  context 'when #operate_from_file' do
    it 'creates 3 installations in 2 batches when batch size is 2' do
      filename = Rails.root.join('db/seeds/installations_sample_rspec.csv')
      expect do
        described_class.operate_from_file(filename, 2, Installation, 'validation', {})
        described_class.operate_from_file(filename, 2, Installation, 'upsertion', {})
      end.to change(Installation, :count).from(0).to(3)
    end

    it 'creates 21 classements in 11 batches when batch size is 2' do
      filename = Rails.root.join('db/seeds/classements_sample_rspec.csv')
      installation = FactoryBot.create(:installation)
      expect do
        mapping = { '0065.18698' => installation.id }
        described_class.operate_from_file(filename, 2, Classement, 'validation', mapping)
        described_class.operate_from_file(filename, 2, Classement, 'upsertion', mapping)
      end.to change(Classement, :count).from(0).to(21)
    end

    it 'creates 5 aps in 1 batch when batch size is 10' do
      filename = Rails.root.join('db/seeds/aps_sample_rspec.csv')
      installation = FactoryBot.create(:installation)
      expect do
        mapping = { '0065.00005' => installation.id }
        described_class.operate_from_file(filename, 10, AP, 'validation', mapping)
        described_class.operate_from_file(filename, 10, AP, 'upsertion', mapping)
      end.to change(AP, :count).from(0).to(5)
    end
  end

  context 'when #find_id_in_db' do
    it 'returns nil for Installation if the object does not exist in db' do
      hash = { 's3ic_id' => '0065.00005' }
      mapping_in_db = { '0000.00000': 1 }
      expect(described_class.find_id_in_db(Installation, hash, mapping_in_db)).to be_nil
    end

    it 'returns nil for AP if the object does not exist in db' do
      hash = { 'georisques_id' => 'gid' }
      mapping_in_db = { 'other_gid' => 1 }
      expect(described_class.find_id_in_db(AP, hash, mapping_in_db)).to be_nil
    end

    it 'returns the id in the mapping for Installation if the object exists in db' do
      hash = { 's3ic_id' => '0065.00005' }
      mapping_in_db = { '0065.00005' => 1 }
      expect(described_class.find_id_in_db(Installation, hash, mapping_in_db)).to eq(1)
    end

    it 'returns the id in the mapping for AP if the object exists in db' do
      hash = { 'georisques_id' => 'gid' }
      mapping_in_db = { 'gid' => 1 }
      expect(described_class.find_id_in_db(AP, hash, mapping_in_db)).to eq(1)
    end

    it 'returns nil for Classement' do
      hash = {}
      mapping_in_db = {}
      expect(described_class.find_id_in_db(Classement, hash, mapping_in_db)).to be_nil
    end
  end
end
