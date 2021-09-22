# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include FicheInspectionHelper
end

RSpec.describe FicheInspectionHelper do
  before do
    User.create(id: 1)
    FactoryBot.create(:installation, id: 1)
  end

  let(:prescription1_am) { FactoryBot.create(:prescription, content: 'line 3', rank: '1.1.2', alinea_id: '0') }
  let(:prescription2_am) { FactoryBot.create(:prescription, content: "line 1\nline 2", rank: '1', alinea_id: '1') }
  let(:prescription_table_am) { FactoryBot.create(:prescription, :table, rank: '3', alinea_id: '2') }
  let(:prescription_ap) { FactoryBot.create(:prescription, :from_ap, content: 'content ap', alinea_id: '3') }
  let(:prescription_other_am) { FactoryBot.create(:prescription, :other_am, alinea_id: '4') }

  context 'when #merge_prescriptions_having_same_ref' do
    it 'returns grouped and sorted prescription contents when called with several prescriptions' do
      merged = [['am-id - ref', ["line 1\nline 2", 'line 3']]]
      expect(merge_prescriptions_having_same_ref([prescription1_am, prescription2_am])).to eq merged
    end

    it 'returns grouped and sorted prescription contents when called with several prescriptions from AP and AM' do
      prescriptions = [prescription1_am, prescription_ap]
      merged = [['am-id - ref', ['line 3']], ['AP 2020 - ref', ['content ap']]]
      expect(merge_prescriptions_having_same_ref(prescriptions)).to eq merged
    end

    it 'instantiates table with OpenStruct when there is one' do
      prescriptions = [prescription1_am, prescription_table_am]
      group = merge_prescriptions_having_same_ref(prescriptions)[0][1]
      expect(group.map(&:class)).to eq [String, OpenStruct]
    end
  end

  context 'when #prepare_gun_env_rows' do
    it 'groups prescriptions with same text_reference and reference and creates variables' do
      prescriptions = [prescription1_am, prescription_other_am, prescription2_am, prescription_ap]
      all_variables = prepare_gun_env_rows(prescriptions).row_variables.flatten
      expect(
        all_variables.filter { |v| v.placeholder == '[PRESCRIPTION]' }.map(&:value_list)
      ).to eq [["line 1\nline 2\nline 3"], ['content'], ['content ap']]
    end
  end
end
