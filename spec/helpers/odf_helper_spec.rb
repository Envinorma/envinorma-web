# frozen_string_literal: true

require 'rails_helper'
require './app/helpers/odf_helper'

RSpec.configure do |c|
  c.include OdfHelper
end

RSpec.describe OdfHelper do
  context 'when #sanitize' do
    it 'does nothing to empty string' do
      expect(sanitize('')).to eq ''
    end

    it 'replaces line breaks' do
      expect(sanitize("foo\nbar")).to eq 'foo<text:line-break/>bar'
    end

    it 'replaces escape special xml chars and line breaks' do
      expect(sanitize("foo\nP < 5\nbar")).to eq 'foo<text:line-break/>P &lt; 5<text:line-break/>bar'
    end
  end

  context 'when #odf_linebreak' do
    it 'replaces line breaks even with special chars' do
      expect(odf_linebreak("foo\nP < 5\nbar")).to eq 'foo<text:line-break/>P < 5<text:line-break/>bar'
    end
  end

  context 'when #html_escape' do
    it 'replaces escape special xml chars' do
      expect(html_escape("foo\nP < 5\nbar")).to eq "foo\nP &lt; 5\nbar"
    end
  end

  context 'when #compute_cell_content' do
    it 'returns empty string when called with no prescription' do
      expect(compute_cell_content([])).to eq ''
    end

    it 'returns cell content when called with one prescription' do
      prescription = Prescription.new(
        reference: 'ref',
        content: 'content',
        alinea_id: '0',
        from_am_id: nil,
        text_reference: 'AP 2020',
        rank: '1',
        user_id: 0
      )
      expect(compute_cell_content([prescription])).to eq 'content'
    end

    it 'returns concatenated prescription content when called with several prescriptions' do
      prescription1 = Prescription.new(reference: 'ref', content: 'line 3', alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'AP 2020',
                                       rank: '1.1.2', user_id: 0)
      prescription2 = Prescription.new(reference: 'ref', content: "line 1\nline 2", alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'AP 2020',
                                       rank: '0', user_id: 0)
      prescriptions = [prescription1, prescription2]
      result = 'line 3<text:line-break/><text:line-break/>line 1<text:line-break/>line 2'
      expect(compute_cell_content(prescriptions)).to eq result
    end
  end

  context 'when #merge_prescriptions_with_same_ref' do
    it 'returns grouped and sorted prescription contents when called with several prescriptions' do
      prescription1 = Prescription.new(reference: 'ref', content: 'line 3', alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'am-id',
                                       rank: '1.1.2', user_id: 0)
      prescription2 = Prescription.new(reference: 'ref', content: "line 1\nline 2", alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'am-id',
                                       rank: '0', user_id: 0)
      prescriptions = [prescription1, prescription2]
      result = { 'am-id - ref' => 'line 1<text:line-break/>line 2<text:line-break/><text:line-break/>line 3' }
      expect(merge_prescriptions_with_same_ref(prescriptions)).to eq result
    end

    it 'returns grouped and sorted prescription contents when called with several prescriptions from AP and AM' do
      prescription1 = Prescription.new(reference: 'Art. 1', content: 'line 3', alinea_id: '2',
                                       from_am_id: 'am-id', text_reference: 'AM 2020', rank: '1', user_id: 0)
      prescription2 = Prescription.new(reference: 'Annexe 2.', content: "line 1\nline 2", alinea_id: '0',
                                       from_am_id: 'am-id', text_reference: 'AP 2009', rank: '0', user_id: 0)
      prescriptions = [prescription1, prescription2]
      result = { 'AM 2020 - Art. 1' => 'line 3', 'AP 2009 - Annexe 2.' => 'line 1<text:line-break/>line 2' }
      expect(merge_prescriptions_with_same_ref(prescriptions)).to eq result
    end
  end
end
