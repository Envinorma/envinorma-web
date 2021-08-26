# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Odf::XmlHelpers
end

RSpec.describe Odf::XmlHelpers do
  context 'when #replace_in_xml' do
    it 'does nothing when xml does not contain variable' do
      xml = Nokogiri::XML('<foo/>')
      replace_in_xml(xml, 'VARIABLE', 'VALUE', true)
      expect(xml.xpath('foo').to_s).to eq '<foo/>'
    end

    it 'replaces all variable occurrences in xml' do
      xml = Nokogiri::XML('<root><foo>VAR_1</foo><bar><foo>VAR_2</foo>VAR_1</bar></root>')
      replace_in_xml(xml, 'VAR_1', 'VALUE_1', true)
      expected = Nokogiri::XML('<root><foo>VALUE_1</foo><bar><foo>VAR_2</foo>VALUE_1</bar></root>')
      expect(xml.to_s).to eq expected.to_s
    end

    it 'sanitizes and replaces the value when sanitize is true' do
      xml = Nokogiri::XML('<root><foo>VAR_1</foo></root>')
      replace_in_xml(xml, 'VAR_1', "FOO\nBAR", true)
      expected = Nokogiri::XML('<root><foo>FOO<text:line-break/>BAR</foo></root>')
      expect(xml.to_s).to eq expected.to_s
    end

    it 'replaces without sanitizing the value when sanitize is true' do
      xml = Nokogiri::XML('<root><foo>VAR_1</foo></root>')
      replace_in_xml(xml, 'VAR_1', "FOO\nBAR", false)
      expected = Nokogiri::XML("<root><foo>FOO\nBAR</foo></root>")
      expect(xml.to_s).to eq expected.to_s
    end
  end

  context 'when #deep_clone' do
    it 'clones tree node allowing edition on the copy' do
      xml = Nokogiri::XML(
        '<root xmlns:text="c" xmlns:table="d"><text:section><table:table></table:table></text:section></root>'
      )
      copy = deep_clone(xml.xpath('//text:section').first)
      copy.xpath('//table:table').first.add_child('<table:table-row/>')
      expected = "<text:section>\n  <table:table><table:table-row/></table:table>\n</text:section>"
      expect(copy.to_s).to eq expected
    end

    it 'clones tree node so that initial node is not affected by a modification of the copy' do
      xml_str = '<root xmlns:text="c" xmlns:table="d"><text:section><table:table></table:table></text:section></root>'
      xml = Nokogiri::XML(xml_str)
      copy = deep_clone(xml.xpath('//text:section').first)
      copy.xpath('//table:table').first.add_child('<table:table-row/>')
      expected = "<root xmlns:text=\"c\" xmlns:table=\"d\">\n  <text:section>"\
                 "\n    <table:table/>\n  </text:section>\n</root>"
      expect(xml.xpath('root').to_s).to eq expected
    end
  end

  context 'when #find_table' do
    it 'finds table by name' do
      xml_str = '<root xmlns:text="c" xmlns:table="d"><text:section><table:table table:name="test">'\
                '</table:table></text:section></root>'
      xml = Nokogiri::XML(xml_str)

      expect(find_table(xml, 'test')).not_to be_nil
    end

    it 'raises an error when table is not found' do
      xml_str = '<root xmlns:text="c" xmlns:table="d"><text:section><table:table table:name="test">'\
                '</table:table></text:section></root>'
      xml = Nokogiri::XML(xml_str)

      expect { find_table(xml, 'test2') }.to raise_error(RuntimeError)
    end

    it 'raises an error when table is found multiple times' do
      xml_str = '<root xmlns:text="c" xmlns:table="d"><text:section><table:table table:name="test">'\
                '</table:table><table:table table:name="test"></table:table></text:section></root>'
      xml = Nokogiri::XML(xml_str)

      expect { find_table(xml, 'test') }.to raise_error(RuntimeError)
    end
  end
end
