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

  context 'when :human_readable_volume' do
    it 'does not transform empty volume' do
      classement = described_class.new(volume: '')
      expect(classement.human_readable_volume).to eq ''
    end

    it 'removes useless trailing zeros for integer values' do
      classement = described_class.new(volume: '10.000 m3')
      expect(classement.human_readable_volume).to eq '10 m3'
    end

    it 'leaves number unchanged if it is an int' do
      classement = described_class.new(volume: '10 m3')
      expect(classement.human_readable_volume).to eq '10 m3'
    end

    it 'removes useless trailing zeros for decimal values' do
      classement = described_class.new(volume: '10.030 t')
      expect(classement.human_readable_volume).to eq '10.03 t'
    end

    it 'works the same when comma is used instead of dot' do
      classement = described_class.new(volume: '10,030 t')
      expect(classement.human_readable_volume).to eq '10.03 t'
    end

    it 'does nothing when no trailing zeros' do
      classement = described_class.new(volume: '10.035 h')
      expect(classement.human_readable_volume).to eq '10.035 h'
    end

    it 'removes useless trailing zeros even when volume has no unit' do
      classement = described_class.new(volume: '10.000')
      expect(classement.human_readable_volume).to eq '10'
    end

    it 'removes useless trailing zeros even when volume has no unit and trailing whitespace' do
      classement = described_class.new(volume: '10.000 ')
      expect(classement.human_readable_volume).to eq '10'
    end

    it 'simplifies volume when volume has more than one space' do
      classement = described_class.new(volume: '10.000 m3 t')
      expect(classement.human_readable_volume).to eq '10 m3 t'
    end
  end
end
