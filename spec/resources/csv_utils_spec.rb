# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CsvUtils do
  context 'when #read_column' do
    it 'reads column values from file' do
      filename = Rails.root.join('db/seeds/installations_sample_rspec.csv')
      expect(described_class.read_column(filename, 'regime')).to eq %w[A E A]
    end
  end
end
