# frozen_string_literal: true

require 'rails_helper'
require './app/helpers/odf_helper'

RSpec.configure do |c|
  c.include OdfHelper
end

RSpec.describe '#sanitize' do
  it 'should do nothing to empty string' do
    expect(sanitize('')).to eq ''
  end

  it 'should replace line breaks' do
    expect(sanitize("foo\nbar")).to eq 'foo<text:line-break/>bar'
  end

  it 'should replace escape special xml chars and line breaks' do
    expect(sanitize("foo\nP < 5\nbar")).to eq 'foo<text:line-break/>P &lt; 5<text:line-break/>bar'
  end
end

RSpec.describe '#odf_linebreak' do
  it 'should replace line breaks' do
    expect(odf_linebreak("foo\nP < 5\nbar")).to eq 'foo<text:line-break/>P < 5<text:line-break/>bar'
  end
end

RSpec.describe '#html_escape' do
  it 'should replace escape special xml chars' do
    expect(html_escape("foo\nP < 5\nbar")).to eq "foo\nP &lt; 5\nbar"
  end
end
