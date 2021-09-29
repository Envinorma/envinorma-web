# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations
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

    it 'removes installation with its classements when it does not exist in files.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0123.45678')
      classement = Classement.create!(regime: 'A', rubrique: '1419', installation_id: installation.id)
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Installation.where(id: installation.id).count).to be_zero
      expect(Classement.where(id: classement.id).count).to be_zero
    end

    it 'updates installation when it exists in file.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0065.00005')
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Installation.find(installation.id).name).to eq('ACOLYANCE')
    end

    it 'does not remove duplicated installations and classements.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0123.45678', duplicated_from_id: 3)
      classement = Classement.create!(regime: 'A', rubrique: '1419', installation_id: installation.id)
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Installation.find(installation.id)).to be_present
      expect(Classement.find(classement.id)).to be_present
    end

    it 'does not remove fictive installations and classements.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0000.00000')
      classement = Classement.create!(regime: 'A', rubrique: '1419', installation_id: installation.id)
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(Installation.find(installation.id)).to be_present
      expect(Classement.find(classement.id)).to be_present
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
                      installation_s3ic_id: installation.s3ic_id, ocr_status: 'SUCCESS')
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(AP.where(id: ap.id).count).to be_zero
    end

    it 'updates AP if it exists in file.' do
      installation = Installation.create!(name: 'test', s3ic_id: '0065.00005')
      ap = AP.create!(georisques_id: 'P/4/8acb34015a601eb2015a602221ca0004', installation_id: installation.id,
                      installation_s3ic_id: installation.s3ic_id, description: 'test', ocr_status: 'SUCCESS')
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      expect(AP.find(ap.id).description).to eq('Nouveau document')
    end
  end

  context 'when #update_aps' do
    it 'seeds AP only by deleting APs that dont exist anymore and creating APs that dont exist yet' do
      described_class.seed_installations_and_associations(validate: true, use_sample: true)
      AP.last.delete
      AP.create!(georisques_id: 'A/1/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', installation_id: Installation.last.id,
                 installation_s3ic_id: Installation.last.s3ic_id, ocr_status: 'SUCCESS')
      described_class.update_aps(from_ovh: false, use_sample: true)
      ids = Set.new(AP.pluck(:georisques_id))
      expected_ids = Set.new(
        %w[
          P/c/b6896c18c4964031a644c67b4618d88c P/4/accddfc8ec3941998ad0588c071c39d4
          P/c/91e4aacb00994b34898f78f3182f543c P/1/29cdec79afe1484aac478c0d06d79901
          P/4/8acb34015a601eb2015a602221ca0004
        ]
      )
      expect(ids).to eq(expected_ids)
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
