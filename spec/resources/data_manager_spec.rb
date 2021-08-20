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

    it 'removes installation when it does not exist in files.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0000.00000')
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Installation.where(id: installation.id).count).to be_zero
    end

    it 'updates installation when it exists in file.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0065.00005')
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Installation.find(installation.id).name).to eq('ACOLYANCE')
    end

    it 'does not remove duplicated installations.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0000.00000', duplicated_from_id: 3)
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Installation.find(installation.id)).to be_present
    end

    it 'does not update duplicated installation when it exists in file.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0065.00005', duplicated_from_id: 3)
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Installation.find(installation.id).name).to eq('test')
    end

    it 'does not remove classements from duplicated installation.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0065.00005', duplicated_from_id: 3)
      classement = Classement.create!(regime: 'A', rubrique: '1419', installation_id: installation.id)
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Classement.find(classement.id)).to eq(classement)
    end

    it 'does not remove prescription if installation is updated.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0065.00005')
      prescription = Prescription.create!(user_id: User.create.id, installation_id: installation.id)
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Prescription.find(prescription.id)).not_to be_nil
    end

    it 'deletes AP if it does not exist in file.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0065.00005')
      ap = AP.create!(georisques_id: 'A/b/8acb34015a601eb2015a602221ca0004', installation_id: installation.id,
                      installation_s3ic_id: installation.s3ic_id)
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(AP.where(id: ap.id).count).to be_zero
    end

    it 'updates AP if it exists in file.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0065.00005')
      ap = AP.create!(georisques_id: 'P/4/8acb34015a601eb2015a602221ca0004', installation_id: installation.id,
                      installation_s3ic_id: installation.s3ic_id, description: 'test')
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(AP.find(ap.id).description).to eq('Nouveau document')
    end
  end
end
