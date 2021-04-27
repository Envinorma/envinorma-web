# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Classement.new do
  it 'should do nothing to empty string' do
    expect(Classement.new.simplify_volume('')).to eq ''
  end

  it 'should do nothing to nil' do
    expect(Classement.new.simplify_volume(nil)).to eq nil
  end

  it 'should do nothing to a string' do
    expect(Classement.new.simplify_volume('10 m3')).to eq '10 m3'
  end

  it 'should do nothing to a string with a dot' do
    expect(Classement.new.simplify_volume('10.m3')).to eq '10.m3'
  end

  it 'should extract int if all digits after . are 0' do
    expect(Classement.new.simplify_volume('0.000')).to eq 0
  end

  it 'should extract int if all digits after . are 0' do
    expect(Classement.new.simplify_volume('325.000')).to eq 325
  end

  it 'should extract float without trailing 0' do
    expect(Classement.new.simplify_volume('0.0001')).to eq 0.0001
  end

  it 'should extract float without trailing 0' do
    expect(Classement.new.simplify_volume('6.340')).to eq 6.34
  end

  it 'should not transform empty volume' do
    classement = Classement.new(volume: '')
    expect(classement.human_readable_volume).to eq ''
  end

  it 'should not transform volume when volume has more than one space' do
    classement = Classement.new(volume: '10.000 m3 t')
    expect(classement.human_readable_volume).to eq '10.000 m3 t'
  end

  it 'should remove useless trailing zeros' do
    classement = Classement.new(volume: '10.000 m3')
    expect(classement.human_readable_volume).to eq '10 m3'
  end

  it 'should remove useless trailing zeros' do
    classement = Classement.new(volume: '10.030 t')
    expect(classement.human_readable_volume).to eq '10.03 t'
  end

  it 'should remove useless trailing zeros' do
    classement = Classement.new(volume: '10.035 h')
    expect(classement.human_readable_volume).to eq '10.035 h'
  end

  it 'should remove useless trailing zeros even when volume has no unit' do
    classement = Classement.new(volume: '10.000')
    expect(classement.human_readable_volume).to eq '10'
  end
end
