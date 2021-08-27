# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Odf::Variables
  c.include Odf::XmlHelpers
end

RSpec.describe Odf::Variables do
  context 'when #contains_table?' do
    it 'returns true if one of the values is an OpenStruct' do
      struct = JSON.parse('{"foo": "bar"}', object_class: OpenStruct)
      variable = Odf::Variables::Variable.new('name', ['string', struct])
      expect(variable.contains_table?).to be true
    end

    it 'returns false if none of the values is an OpenStruct' do
      variable = Odf::Variables::Variable.new('name', %w[foo bar])
      expect(variable.contains_table?).to be false
    end
  end

  context 'when #replace_variable' do
    # rubocop:disable RSpec/ExampleLength
    it 'replaces the variable with the values, table being instantiated with template' do
      path = Rails.root.join('spec/fixtures/fiche_inspection/table.json')
      table_struct = JSON.parse(File.read(path), object_class: OpenStruct)
      table_template = find_table(
        Nokogiri::XML(
          <<~XML
            <root xmlns:text="c" xmlns:table="d">
              <table:table table:name="table-template">
                <table:table-column />
                <table:table-row>
                  <table:table-cell>[CELL_PLACEHOLDER]</table:table-cell>
                </table:table-row>
              </table:table>
            </root>
          XML
        ),
        'table-template'
      )
      table_templates = { 'table-template' => table_template }
      document = Nokogiri::XML(
        <<~XML
          <root xmlns:text="c" xmlns:table="d">
            <text:p>[PLACEHOLDER]</text:p>
          </root>
        XML
      )
      variable = Odf::Variables::Variable.new(
        '[PLACEHOLDER]', ['hello', table_struct, 'world'], 2, 'table-template', '[CELL_PLACEHOLDER]'
      )
      replace_variable(document, variable, table_templates)
      expected = Nokogiri::XML(
        <<~XML
          <root xmlns:text="c" xmlns:table="d">
            <text:p>hello</text:p>
            <text:p/>
            <table:table table:name="table-template">
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
            <text:p/>
            <text:p>world</text:p>
            <text:p/>
          </root>
        XML
      )
      expect(document.to_s.gsub(/\s/, '')).to eq(expected.to_s.gsub(/\s/, ''))
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
