# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Classement do
  context 'when #simplify_volume' do
    it 'does nothing to empty string' do
      expect(described_class.new.simplify_volume('')).to be_nil
    end

    it 'does nothing to nil' do
      expect(described_class.new.simplify_volume(nil)).to eq nil
    end

    it 'does nothing to a string' do
      expect(described_class.new.simplify_volume('10 m3')).to eq '10 m3'
    end

    it 'does nothing to a string with a dot' do
      expect(described_class.new.simplify_volume('10.m3')).to eq '10.m3'
    end

    it 'extracts int if all digits after . are 0' do
      expect(described_class.new.simplify_volume('325.000')).to eq 325
    end

    it 'extracts int if all digits after . are 0 even for zero' do
      expect(described_class.new.simplify_volume('0.000')).to eq 0
    end

    it 'extracts int if no decimal digits' do
      expect(described_class.new.simplify_volume('10')).to eq 10
    end

    it 'extracts float without trailing 0 when there are no trailing zeros' do
      expect(described_class.new.simplify_volume('0.0001')).to eq 0.0001
    end

    it 'extracts float without trailing 0  when there are trailing zeros' do
      expect(described_class.new.simplify_volume('6.340')).to eq 6.34
    end
  end

  context 'when :volume' do
    it 'does not transform empty volume' do
      classement = described_class.new(volume: '')
      expect(classement.volume).to eq ''
    end

    it 'removes useless trailing zeros for integer values' do
      classement = described_class.new(volume: '10.000 m3')
      expect(classement.volume).to eq '10 m3'
    end

    it 'leaves number unchanged if it is an int' do
      classement = described_class.new(volume: '10 m3')
      expect(classement.volume).to eq '10 m3'
    end

    it 'removes useless trailing zeros for decimal values' do
      classement = described_class.new(volume: '10.030 t')
      expect(classement.volume).to eq '10.03 t'
    end

    it 'works the same when comma is used instead of dot' do
      classement = described_class.new(volume: '10,030 t')
      expect(classement.volume).to eq '10.03 t'
    end

    it 'does nothing when no trailing zeros' do
      classement = described_class.new(volume: '10.035 h')
      expect(classement.volume).to eq '10.035 h'
    end

    it 'removes useless trailing zeros even when volume has no unit' do
      classement = described_class.new(volume: '10.000')
      expect(classement.volume).to eq '10'
    end

    it 'removes useless trailing zeros even when volume has no unit and trailing whitespace' do
      classement = described_class.new(volume: '10.000 ')
      expect(classement.volume).to eq '10'
    end

    it 'simplifies volume when volume has more than one space' do
      classement = described_class.new(volume: '10.000 m3 t')
      expect(classement.volume).to eq '10 m3 t'
    end
  end

  # rubocop:disable RSpec/MultipleExpectations
  context 'when update classement' do
    it 'updates volume if it has the good format' do
      installation_eva_industries = FactoryBot.create(:installation)
      classement = FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)

      classement.update!(volume: '25 m3')
      expect(classement.volume).to eq '25 m3'

      classement.update!(volume: '70.0 MW')
      expect(classement.volume).to eq '70.0 MW'

      classement.update!(volume: '70')
      expect(classement.volume).to eq '70'

      classement.update!(volume: '70,0 MW')
      expect(classement.volume).to eq '70.0 MW'
    end

    it 'does not pass validation if volume does not start with a number' do
      installation_eva_industries = FactoryBot.create(:installation)
      classement = FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)

      classement.update(volume: 'm3')
      expect { classement.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not pass validation if volume does not have space between number and unity' do
      installation_eva_industries = FactoryBot.create(:installation)
      classement = FactoryBot.create(:classement, :classement_2521_E, installation: installation_eva_industries)

      classement.update(volume: '20m3')
      expect { classement.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
  # rubocop:enable RSpec/MultipleExpectations
end
