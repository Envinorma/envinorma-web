# frozen_string_literal: true

require 'rails_helper'
require './app/helpers/prescriptions_grouping_helper'

RSpec.configure do |c|
  c.include PrescriptionsGroupingHelper
end

RSpec.describe PrescriptionsGroupingHelper do
  it 'sorts prescriptions by creation date when different AM.' do
    prescription1 = Prescription.new(reference: '', content: '', alinea_id: '0', from_am_id: 'am-id-1',
                                     text_reference: 'AM 1', rank: '1.1.2', user_id: 0,
                                     created_at: '2020/01/02'.to_date)
    prescription2 = Prescription.new(reference: '', content: '', alinea_id: '1', from_am_id: 'am-id-2',
                                     text_reference: 'AM 0', rank: '0', user_id: 0, created_at: '2020/01/01'.to_date)
    prescriptions = [prescription1, prescription2]
    output_prescriptions = sort_and_group(prescriptions).values.map(&:values).flatten
    expect(output_prescriptions).to eq [prescription2, prescription1]
  end

  it 'sorts prescriptions by taking AM prescriptions before AP prescriptions.' do
    prescription1 = Prescription.new(reference: '', content: '', alinea_id: '1', from_am_id: nil, text_reference: 'AP',
                                     rank: '0', user_id: 0, created_at: '2020/01/01'.to_date)
    prescription2 = Prescription.new(reference: '', content: '', alinea_id: '0', from_am_id: 'am-id',
                                     text_reference: 'AM', rank: '1.1.2', user_id: 0, created_at: '2020/01/02'.to_date)
    prescriptions = [prescription1, prescription2]
    output_prescriptions = sort_and_group(prescriptions).values.map(&:values).flatten
    expect(output_prescriptions).to eq [prescription2, prescription1]
  end

  # rubocop:disable RSpec/MultipleExpectations

  it 'groups prescriptions by text then reference, sorted by rank.' do
    prescription1 = Prescription.new(reference: 'ref-ap', content: '', alinea_id: '1', from_am_id: nil,
                                     text_reference: 'AP', rank: '0', user_id: 0, created_at: '2020/01/01'.to_date)
    prescription2 = Prescription.new(reference: 'ref', content: '', alinea_id: '2', from_am_id: 'am-id',
                                     text_reference: 'AM', rank: '1.4.2', user_id: 0, created_at: '2020/01/02'.to_date)
    prescription3 = Prescription.new(reference: 'ref', content: '', alinea_id: '3', from_am_id: 'am-id',
                                     text_reference: 'AM', rank: '1.3.2', user_id: 0, created_at: '2020/01/03'.to_date)
    prescription4 = Prescription.new(reference: 'ref-2', content: '', alinea_id: '3', from_am_id: 'am-id',
                                     text_reference: 'AM', rank: '2', user_id: 0, created_at: '2020/01/01'.to_date)
    prescriptions = [prescription1, prescription2, prescription3, prescription4]
    expected = { 'AM' => { 'ref-2' => [prescription4], 'ref' => [prescription3, prescription2] },
                 'AP' => { 'ref-ap' => [prescription1] } }
    output_prescriptions = sort_and_group(prescriptions)
    expect(output_prescriptions).to eq expected
    new_order = [prescription3, prescription2, prescription4, prescription1]
    expect(output_prescriptions.values.map(&:values).flatten).to eq new_order
  end
  # rubocop:enable RSpec/MultipleExpectations
end
