# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |c|
  c.include Odf::Sanitizer
end

RSpec.describe Odf::Sanitizer do
  context 'when #sanitize_odt_xml' do
    it 'does nothing to empty string' do
      expect(sanitize_odt_xml('')).to eq ''
    end

    it 'replaces line breaks' do
      expect(sanitize_odt_xml("foo\nbar")).to eq 'foo<text:line-break/>bar'
    end

    it 'replaces escape special xml chars and line breaks' do
      expect(sanitize_odt_xml("foo\nP < 5\nbar")).to eq 'foo<text:line-break/>P &lt; 5<text:line-break/>bar'
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
end
