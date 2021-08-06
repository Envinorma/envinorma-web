# frozen_string_literal: true

require 'rails_helper'
require './app/controllers/concerns/filter_ams'

RSpec.configure do |c|
  c.include FilterAMs
end

RSpec.describe FilterAMs do # rubocop:disable RSpec/FilePath
  context 'when :date_in_range' do
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

    it 'returns false if candidate date is equal to right_date.' do
      expect(date_in_range('2020-01-01'.to_date, nil, '2020-01-01')).to eq false
    end

    it 'returns true if candidate date is equal to left_date.' do
      expect(date_in_range('2020-01-01'.to_date, '2020-01-01', nil)).to eq true
    end
  end

  context 'when :date_match' do
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

  context 'when :alineas_match?' do
    it 'returns false if no classement are given' do
      expect(alineas_match?(FactoryBot.create(:am, :fake_am_1_default), [])).to eq false
    end

    it 'returns true if one classement with matching alinea is given' do
      classement = Classement.new(rubrique: '1234', regime: 'D', alinea: '1')
      expect(alineas_match?(FactoryBot.create(:am, :fake_am_1_default), [classement])).to eq true
    end

    it 'returns false if all given classements have matching alinea' do
      classement1 = Classement.new(rubrique: '1234', regime: 'D', alinea: '11')
      classement2 = Classement.new(rubrique: '1234', regime: 'D', alinea: 'A')
      expect(alineas_match?(FactoryBot.create(:am, :fake_am_1_default), [classement1, classement2])).to eq false
    end

    it 'returns true if any given classements have matching alinea' do
      classement1 = Classement.new(rubrique: '1234', regime: 'D', alinea: '1')
      classement2 = Classement.new(rubrique: '1234', regime: 'D', alinea: 'A')
      expect(alineas_match?(FactoryBot.create(:am, :fake_am_1_default), [classement1, classement2])).to eq true
    end

    it 'returns true if am classement does not depend on alinea' do
      am = FactoryBot.create(:am, :fake_am_1_default)
      classements_with_alineas = [{ rubrique: '1234', regime: 'E', alineas: [] }]
      am.update!(classements_with_alineas: classements_with_alineas)
      classement1 = Classement.new(rubrique: '1234', regime: 'E', alinea: '1')
      expect(alineas_match?(am, [classement1])).to eq true
    end

    it 'returns true if any given classements have matching alinea and AM has several classements' do
      am = FactoryBot.create(:am, :fake_am_1_default)
      classements_with_alineas = [{ rubrique: '1234', regime: 'D', alineas: ['1'] },
                                  { rubrique: '1234', regime: 'E', alineas: [] }]
      am.update!(classements_with_alineas: classements_with_alineas)

      classement2 = Classement.new(rubrique: '1234', regime: 'D', alinea: 'A')
      classement1 = Classement.new(rubrique: '1234', regime: 'E', alinea: '1')
      expect(alineas_match?(am, [classement1, classement2])).to eq true
    end
  end
end
