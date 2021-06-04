# frozen_string_literal: true

require 'rails_helper'
require './app/controllers/concerns/filter_arretes'

RSpec.configure do |c|
  c.include FilterArretes
end

RSpec.describe 'date_in_range' do
  it 'returns true if candidate is in range.' do
    expect(date_in_range('2020-01-01'.to_date, '2019-01-01', '2021-01-01')).to eq true
  end

  it 'returns false if candidate is not in range.' do
    expect(date_in_range('2022-01-01'.to_date, '2019-01-01', '2021-01-01')).to eq false
  end

  it 'returns true if left date is nil and right date is above candidate.' do
    expect(date_in_range('2020-01-01'.to_date, nil, '2021-01-01')).to eq true
  end

  it 'returns true if left date is nil and right date is below candidate.' do
    expect(date_in_range('2022-01-01'.to_date, nil, '2021-01-01')).to eq false
  end

  it 'returns true if right date is nil and left date is below candidate.' do
    expect(date_in_range('2020-01-01'.to_date, '2019-01-01', nil)).to eq true
  end

  it 'returns true if right date is nil and left date is above candidate.' do
    expect(date_in_range('2020-01-01'.to_date, '2021-01-01', nil)).to eq false
  end
end

RSpec.describe 'date_match' do
  it 'returns true if date is not used in parametrization.' do
    date_parameter_descriptor = {
      'is_used_in_parametrization' => false,
      'unknown_classement_date_version' => nil,
      'left_value' => nil,
      'right_value' => nil
    }

    expect(date_match(date_parameter_descriptor, '2020-01-01'.to_date)).to eq true
  end

  it 'returns true if version is the unknown date version and classement date is nil.' do
    date_parameter_descriptor = {
      'is_used_in_parametrization' => true,
      'unknown_classement_date_version' => true,
      'left_value' => nil,
      'right_value' => nil
    }

    expect(date_match(date_parameter_descriptor, nil)).to eq true
  end

  it 'returns false if version is not the unknown date version and classement date is nil.' do
    date_parameter_descriptor = {
      'is_used_in_parametrization' => true,
      'unknown_classement_date_version' => false,
      'left_value' => '2020-01-01',
      'right_value' => nil
    }

    expect(date_match(date_parameter_descriptor, nil)).to eq false
  end

  it 'returns true if version is not the unknown date version and classement date is in range.' do
    date_parameter_descriptor = {
      'is_used_in_parametrization' => true,
      'unknown_classement_date_version' => false,
      'left_value' => '2020-01-01',
      'right_value' => nil
    }

    expect(date_match(date_parameter_descriptor, '2021-01-01'.to_date)).to eq true
  end

  it 'returns false if version is not the unknown date version and classement date is not in range.' do
    date_parameter_descriptor = {
      'is_used_in_parametrization' => true,
      'unknown_classement_date_version' => false,
      'left_value' => '2022-01-01',
      'right_value' => nil
    }

    expect(date_match(date_parameter_descriptor, '2021-01-01'.to_date)).to eq false
  end
end
