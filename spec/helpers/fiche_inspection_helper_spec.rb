# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include FicheInspectionHelper
end

RSpec.describe FicheInspectionHelper do
  context 'when #merge_prescriptions_having_same_ref' do
    it 'returns grouped and sorted prescription contents when called with several prescriptions' do
      prescription1 = Prescription.new(reference: 'ref', content: 'line 3', alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'am-id',
                                       rank: '1.1.2', user_id: 0)
      prescription2 = Prescription.new(reference: 'ref', content: "line 1\nline 2", alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'am-id',
                                       rank: '0', user_id: 0)
      prescriptions = [prescription1, prescription2]
      merged = [['am-id - ref', ["line 1\nline 2", 'line 3']]]
      expect(merge_prescriptions_having_same_ref(prescriptions)).to eq merged
    end

    it 'returns grouped and sorted prescription contents when called with several prescriptions from AP and AM' do
      prescription1 = Prescription.new(reference: 'Art. 1', content: 'line 3', alinea_id: '2',
                                       from_am_id: 'am-id', text_reference: 'AM 2020', rank: '1', user_id: 0)
      prescription2 = Prescription.new(reference: 'Annexe 2.', content: "line 1\nline 2", alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'AP 2009', rank: '0', user_id: 0)
      prescriptions = [prescription1, prescription2]
      merged = [['AM 2020 - Art. 1', ['line 3']], ['AP 2009 - Annexe 2.', ["line 1\nline 2"]]]
      expect(merge_prescriptions_having_same_ref(prescriptions)).to eq merged
    end

    it 'instantiates table when there is one' do
      prescription1 = Prescription.new(reference: 'Art. 1', content: 'line 3', alinea_id: '2',
                                       from_am_id: 'id', text_reference: 'AM 2020', rank: '1')
      prescription2 = Prescription.new(reference: 'Annexe 2.', content: '{"foo": "bar"}', alinea_id: '0',
                                       from_am_id: 'id', text_reference: 'AP 2009', rank: '0', is_table: true)
      prescriptions = [prescription1, prescription2]
      expected = { foo: 'bar' }
      expect(merge_prescriptions_having_same_ref(prescriptions)[1][1][0].to_h).to eq expected
    end
  end

  def build_simple_prescription(content, reference, text_reference)
    Prescription.new(
      reference: reference, content: content, from_am_id: 'id', text_reference: text_reference, rank: '1'
    )
  end

  context 'when #prepare_gun_env_rows' do
    it 'groups prescriptions with same text_reference and reference and creates variables' do
      prescriptions = [
        build_simple_prescription('line 1', 'ref', 'am-id'),
        build_simple_prescription('line 2', 'ref', 'am-id'),
        build_simple_prescription('line 3', 'ref', 'am-id-2'),
        build_simple_prescription('line 4', 'ref-2', 'am-id-2')
      ]
      all_variables = prepare_gun_env_rows(prescriptions).row_variables.flatten
      expect(
        all_variables.filter { |v| v.placeholder == '[PRESCRIPTION]' }.map(&:value_list)
      ).to eq [["line 1\nline 2"], ['line 3'], ['line 4']]
    end
  end
end
