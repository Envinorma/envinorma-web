# frozen_string_literal: true

module Odf
  module XmlHelpers
    include Odf::Sanitizer

    def replace_variables(xml, variable_hash)
      variable_hash.each do |key, value|
        replace_variable(xml, key, value)
      end
    end

    def replace_variable(xml, variable_name, variable_value)
      txt = xml.inner_html
      txt.gsub!(variable_name, sanitize(variable_value))
      xml.inner_html = txt
    end

    def deep_clone(node)
      tag_name = "#{node.namespace.prefix}|#{node.name}"
      Nokogiri::XML(wrap_with_ns(node)).at(tag_name)
    end

    def find_table(xml, table_name)
      results = xml.xpath("//table:table[@table:name='#{table_name}']")

      raise "Table #{table_name} not found" if results.empty?

      raise "Multiple tables #{table_name} found" if results.size > 1

      results.first
    end

    private

    def wrap_with_ns(node)
      <<-XML
       <root xmlns:draw="a" xmlns:xlink="b" xmlns:text="c" xmlns:table="d">#{node.to_xml}</root>
      XML
    end
  end
end