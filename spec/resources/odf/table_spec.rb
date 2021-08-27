# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Odf::Table
end

RSpec.describe Odf::Table do
  context 'when #ensure_one_cell' do
    it 'raises error if xml table has more than one cell' do
      xml = <<~XML
        <root xmlns:text="c" xmlns:table="d">
          <table:table table:name="Table1">
            <table:table-column />
            <table:table-row>
              <table:table-cell />
              <table:table-cell />
            </table:table-row>
          </table:table>
        </root>
      XML
      expect { ensure_one_cell(Nokogiri::XML(xml)) }.to raise_error(RuntimeError)
    end

    it 'returns nil if xml table has exactly one cell' do
      xml = <<~XML
        <root xmlns:text="c" xmlns:table="d">
          <table:table table:name="Table1">
            <table:table-column />
            <table:table-row>
              <table:table-cell />
            </table:table-row>
          </table:table>
        </root>
      XML
      expect(ensure_one_cell(Nokogiri::XML(xml))).to be_nil
    end
  end

  context 'when #table_from_template' do
    it 'generates table in table named Table1 from table struct' do # rubocop:disable RSpec/ExampleLength
      xml = Nokogiri::XML(
        <<~XML
          <root xmlns:text="c" xmlns:table="d">
            <table:table table:name="Table1">
              <table:table-column />
              <table:table-row>
                <table:table-cell>[PLACEHOLDER]</table:table-cell>
              </table:table-row>
            </table:table>
          </root>
        XML
      )
      path = Rails.root.join('spec/fixtures/fiche_inspection/table.json')
      table_struct = JSON.parse(File.read(path), object_class: OpenStruct)
      table_template = xml.at_xpath('//table:table[@table:name="Table1"]')
      expected = <<~XML
        <table:table table:name="Table1">
          <table:table-column />
          <table:table-column />
          <table:table-row>
            <table:table-cell>A</table:table-cell>
            <table:table-cell>B</table:table-cell>
          </table:table-row>
          <table:table-row>
            <table:table-cell>C</table:table-cell>
            <table:table-cell>D</table:table-cell>
          </table:table-row>
        </table:table>
      XML

      result = table_from_template(table_template, table_struct, '[PLACEHOLDER]').to_s.gsub(/\s/, '')
      expect(result).to eq(expected.gsub(/\s/, ''))
    end
  end
end
