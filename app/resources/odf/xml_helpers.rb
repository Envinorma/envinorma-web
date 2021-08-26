# frozen_string_literal: true

module Odf
  module XmlHelpers
    include Odf::Sanitizer

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

    def replace_in_xml(xml, placeholder, value, sanitize)
      txt = xml.inner_html
      txt.gsub!(placeholder, sanitize ? sanitize(value) : value)
      xml.inner_html = txt
    end

    private

    def wrap_with_ns(node)
      <<-XML
       <root xmlns:draw="a" xmlns:xlink="b" xmlns:text="c" xmlns:table="d">#{node.to_xml}</root>
      XML
    end
  end
end
