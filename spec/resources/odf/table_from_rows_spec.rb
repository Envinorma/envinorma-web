# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Odf::TableFromRows
  c.include Odf::Variables
end

RSpec.describe Odf::TableFromRows do
  context 'when #fill_table_rows' do
    # rubocop:disable RSpec/ExampleLength
    it 'repeats rows of the referenced table instantiating variables' do
      xml = Nokogiri::XML(
        <<~XML
          <root xmlns:text="c" xmlns:table="d">
            <table:table table:name="Table1">
              <table:table-column />
              <table:table-row>
                <table:table-cell>[PLACEHOLDER]</table:table-cell><table:table-cell>No variable.</table:table-cell>
              </table:table-row>
            </table:table>
          </root>
        XML
      )
      variables = [
        [Odf::Variables::Variable.new('[PLACEHOLDER]', %w[first row])],
        [Odf::Variables::Variable.new('[PLACEHOLDER]', ['second row'])]
      ]
      table = Odf::TableFromRows::TableRows.new('Table1', variables)
      fill_table_rows(xml, table, {})
      expected = Nokogiri::XML(
        <<~XML
          <root xmlns:text="c" xmlns:table="d">
            <table:table table:name="Table1">
              <table:table-column />
              <table:table-row>
                <table:table-cell>first<text:line-break/>row</table:table-cell><table:table-cell>No variable.</table:table-cell>
              </table:table-row>
              <table:table-row>
                <table:table-cell>second row</table:table-cell><table:table-cell>No variable.</table:table-cell>
              </table:table-row>
            </table:table>
          </root>
        XML
      )
      expect(xml.to_s.gsub(/\s/, '')).to eq(expected.to_s.gsub(/\s/, ''))
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
