# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include ApplicationHelper
end

RSpec.describe '#common_classements' do
  it 'should return nothing when arrete_classement is empty' do
    expect(common_classements([], [])).to eq ''
    expect(common_classements([], [Classement.new(rubrique: '1234', regime: 'A')])).to eq ''
  end

  it 'should return nothing when installation_classements is empty' do
    raw = [{ 'rubrique' => '1234', 'regime' => 'A', 'alineas' => ['1'] }]
    arrete_classements = JSON.parse(raw.to_json, object_class: OpenStruct)
    expect(common_classements(arrete_classements, [])).to eq ''
  end

  it 'should return common classements when there are matches' do
    raw = [{ 'rubrique' => '1234', 'regime' => 'A', 'alineas' => %w[1 B] },
           { 'rubrique' => '2345', 'regime' => 'E', 'alineas' => [] }]
    arrete_classements = JSON.parse(raw.to_json, object_class: OpenStruct)
    installation_classements = [Classement.new(rubrique: '1234', regime: 'A'),
                                Classement.new(rubrique: '3456', regime: 'A')]
    expect(common_classements(arrete_classements, installation_classements)).to eq '1234 A al. 1 ou B'
  end
end
