# frozen_string_literal: true

module Odf
  module XmlHelpers
    include Odf::Sanitizer

    def deep_clone(node)
      tag_name = "#{node.namespace.prefix}:#{node.name}"
      wrap_with_ns(node).at("//#{tag_name}")
    end

    def add_before(node, new_node)
      placeholder = node.add_previous_sibling('<placeholder/>')
      placeholder[0].replace(new_node.to_xml(indent_text: '', indent: 0))
    end

    def find_table(xml, table_name)
      results = xml.xpath("//table:table[@table:name='#{table_name}']")

      raise "Table #{table_name} not found" if results.empty?

      raise "Multiple tables #{table_name} found" if results.size > 1

      results.first
    end

    def replace_in_xml(xml, placeholder, value, sanitize)
      txt = xml.inner_html
      txt.gsub!(placeholder, sanitize ? sanitize_odt_xml(value) : value)
      xml.inner_html = txt
    end

    private

    def wrap_with_ns(node)
      doc = Nokogiri::XML("<root>#{node.to_xml(indent_text: '', indent: 0)}</root>")
      node.namespaces.each do |key, value|
        doc.root.add_namespace(key.split('xmlns:')[1], value)
      end
      Nokogiri::XML(doc.root.to_xml(indent_text: '', indent: 0))
    end
  end
end
