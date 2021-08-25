# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include FicheInspectionHelper
end

RSpec.describe FicheInspectionHelper do
  context 'when #merge_prescriptions_with_same_ref' do
    it 'returns grouped and sorted prescription contents when called with several prescriptions' do
      prescription1 = Prescription.new(reference: 'ref', content: 'line 3', alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'am-id',
                                       rank: '1.1.2', user_id: 0)
      prescription2 = Prescription.new(reference: 'ref', content: "line 1\nline 2", alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'am-id',
                                       rank: '0', user_id: 0)
      prescriptions = [prescription1, prescription2]
      merged = [['am-id - ref', "line 1\nline 2\n\nline 3"]]
      expect(merge_prescriptions_with_same_ref(prescriptions, 0)).to eq [merged, []]
    end

    it 'returns grouped and sorted prescription contents when called with several prescriptions from AP and AM' do
      prescription1 = Prescription.new(reference: 'Art. 1', content: 'line 3', alinea_id: '2',
                                       from_am_id: 'am-id', text_reference: 'AM 2020', rank: '1', user_id: 0)
      prescription2 = Prescription.new(reference: 'Annexe 2.', content: "line 1\nline 2", alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'AP 2009', rank: '0', user_id: 0)
      prescriptions = [prescription1, prescription2]
      merged = [['AM 2020 - Art. 1', 'line 3'], ['AP 2009 - Annexe 2.', "line 1\nline 2"]]
      expect(merge_prescriptions_with_same_ref(prescriptions, 0)).to eq [merged, []]
    end
  end
end
