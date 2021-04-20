# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SearchHelper. For example:
#
# describe SearchHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SearchHelper, type: :helper do
  describe 'split_sentence_on_last_space' do
    it 'should split on last word' do
      expect(split_sentence_on_last_space('Foo bar foo')).to eq ['Foo bar', 'foo']
    end

    it 'should split on last word' do
      expect(split_sentence_on_last_space('Foo bar')).to eq %w[Foo bar]
    end

    it 'should leave last word nil when only one word' do
      expect(split_sentence_on_last_space('Foo')).to eq ['Foo', '']
    end

    it 'should leave last word nil when no words' do
      expect(split_sentence_on_last_space('')).to eq ['', '']
    end
  end

  describe 'build_query' do
    it 'should build simple query when one word' do
      result = ['name ILIKE ? or s3ic_id ILIKE ? or city ILIKE ? or zipcode ILIKE ?',
                '%foo%',
                '%foo%',
                '%foo%',
                '%foo%']
      expect(build_query('Foo')).to eq result
    end

    it 'should build simple query when one word' do
      result = ['name ILIKE ? or s3ic_id ILIKE ? or city ILIKE ? or zipcode ILIKE ?',
                '%foobar%',
                '%foobar%',
                '%foobar%',
                '%foobar%']
      expect(build_query('foobar')).to eq result
    end
    it 'should build complex query when several words' do
      query = 'name ILIKE ? or s3ic_id ILIKE ? or city ILIKE ? or zipcode ILIKE ?'
      result = ["(#{query}) and (#{query})",
                '%foo bar%',
                '%foo bar%',
                '%foo bar%',
                '%foo bar%',
                '%foo%',
                '%foo%',
                '%foo%',
                '%foo%']
      expect(build_query('foo bar foo')).to eq result
    end
    it 'should build complex query when several words' do
      query = 'name ILIKE ? or s3ic_id ILIKE ? or city ILIKE ? or zipcode ILIKE ?'
      result = ["(#{query}) and (#{query})",
                '%foo%',
                '%foo%',
                '%foo%',
                '%foo%',
                '%bar%',
                '%bar%',
                '%bar%',
                '%bar%']
      expect(build_query('foo bar')).to eq result
    end
  end
end
