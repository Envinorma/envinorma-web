# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Odf::Section
  c.include Odf::Variables
end

RSpec.describe Odf::Section do
  context 'when #fill_section' do
    # rubocop:disable RSpec/ExampleLength
    it 'repeats section of the referenced section instantiating variables' do
      xml = Nokogiri::XML(
        <<~XML
          <root xmlns:text="c" xmlns:table="d">
            <text:section text:name="section">
              <text:p text:style-name="P1">[PLACEHOLDER]</text:p>
            </text:section>
          </root>
        XML
      )
      variables = [
        [Odf::Variables::Variable.new('[PLACEHOLDER]', %w[first row])],
        [Odf::Variables::Variable.new('[PLACEHOLDER]', ['second row'])]
      ]
      table = Odf::Section::SectionVariables.new('section', variables, [[], []])
      fill_section(xml, table, {})
      expected = Nokogiri::XML(
        <<~XML
          <root xmlns:text="c" xmlns:table="d">
            <text:section text:name="section">
              <text:p text:style-name="P1">first<text:line-break/>row</text:p>
            </text:section>
            <text:section text:name="section">
              <text:p text:style-name="P1">second row</text:p>
            </text:section>
          </root>
        XML
      )
      expect(xml.to_s.gsub(/\s/, '')).to eq(expected.to_s.gsub(/\s/, ''))
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
