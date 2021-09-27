# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Prescription do
  def json_table
    path = Rails.root.join('spec/fixtures/fiche_inspection/table.json')
    File.read(path)
  end

  context 'when #human_readable_table_content' do
    it 'returns nil if prescription is not a table' do
      expect(described_class.new(is_table: false).human_readable_table_content).to eq nil
    end

    it 'returns cell contents merged with tabs and linebreaks' do
      prescription_with_table = described_class.new(is_table: true, content: json_table)
      expect(prescription_with_table.human_readable_table_content).to eq "A\tB\nC\tD"
    end
  end

  context 'when #human_readable_content' do
    it 'returns content if prescription is not a table' do
      expect(described_class.new(content: 'Contenu', is_table: false).human_readable_content).to eq 'Contenu'
    end

    it 'returns table readable content if prescription is a table' do
      prescription_with_table = described_class.new(is_table: true, content: json_table)
      expect(prescription_with_table.human_readable_content).to eq "A\tB\nC\tD"
    end
  end

  context 'when #text_date' do
    it 'returns nil if no date in string' do
      expect(described_class.new(text_reference: 'AM - 2771 A').text_date).to eq nil
    end

    it 'returns parsed date if date found in string' do
      expect(described_class.new(text_reference: 'AM - 2771 A - 01/10/20').text_date).to eq '2020-10-01'.to_date
    end
  end

  context 'when #reference_number' do
    it 'returns nil if prescription reference is nil' do
      expect(described_class.new(is_table: false, reference: nil).reference_number).to eq nil
    end

    it 'returns article number if reference is an article' do
      expect(described_class.new(is_table: false, reference: 'Article I > 2 b)').reference_number).to eq 'I > 2 b)'
    end

    it 'returns article numbers if reference is a list of articles' do
      expect(described_class.new(is_table: false, reference: 'Articles 3 et 6').reference_number).to eq '3 et 6'
    end

    it 'returns annexe stripped number if reference is an annexe' do
      expect(described_class.new(is_table: false, reference: 'ANNEXE  I').reference_number).to eq 'I'
    end
  end
end
