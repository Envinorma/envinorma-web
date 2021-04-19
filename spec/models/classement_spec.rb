# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Classement.new do
  it 'should do nothing to empty string' do
    expect(Classement.new.simplify_volume('')).to eq ''
  end

  it 'should do nothing to nil' do
    expect(Classement.new.simplify_volume(nil)).to eq nil
  end

  it 'should do nothing to foo' do
    expect(Classement.new.simplify_volume('foo')).to eq 'foo'
  end

  it 'should do nothing to bar' do
    expect(Classement.new.simplify_volume('bar')).to eq 'bar'
  end

  it 'should do nothing to bar.000' do
    expect(Classement.new.simplify_volume('bar.000')).to eq 'bar.000'
  end

  it 'should parse ints' do
    expect(Classement.new.simplify_volume('0.000')).to eq 0
  end

  it 'should parse ints' do
    expect(Classement.new.simplify_volume('325.000')).to eq 325
  end

  it 'should parse floats' do
    expect(Classement.new.simplify_volume('0.0001')).to eq 0.0001
  end

  it 'should parse floats' do
    expect(Classement.new.simplify_volume('6.340')).to eq 6.34
  end
end
