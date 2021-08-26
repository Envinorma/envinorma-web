# frozen_string_literal: true

module Odf
  module Variables
    include Odf::Sanitizer
    include Odf::Table

    class Variable
      attr_reader :placeholder, :value_list, :nb_linebreaks, :template_table_name, :cell_placeholder

      def initialize(placeholder, value_list, nb_linebreaks = 1, template_table_name = nil,
                     cell_placeholder = nil)
        @placeholder = placeholder
        @value_list = value_list
        @nb_linebreaks = nb_linebreaks
        @template_table_name = template_table_name
        @cell_placeholder = cell_placeholder
      end

      def contains_table?
        @value_list.any? { |value| value.is_a?(OpenStruct) }
      end
    end

    def replace_variables(xml, variables, table_templates)
      variables.each do |variable|
        replace_variable(xml, variable, table_templates)
      end
    end

    def replace_variable(xml, variable, table_templates)
      return simple_replacement(xml, variable) unless variable.contains_table?

      placeholder_tag = find_placeholder_tag(xml, variable.placeholder)
      table_template = variable.template_table_name.nil? ? nil : table_templates[variable.template_table_name]
      new_tags = build_new_tags(variable, placeholder_tag, table_template)
      to_insert = insert_linebreaks_between(new_tags, placeholder_tag, variable.nb_linebreaks)
      to_insert.each { |tag| placeholder_tag.before(tag) }
      placeholder_tag.remove
    end

    def simple_replacement(xml, variable)
      value = variable.value_list.join("\n" * variable.nb_linebreaks)
      replace_in_xml(xml, variable.placeholder, value, true)
    end

    def find_placeholder_tag(xml, placeholder)
      searched_tags = %w[//text:p //text:h]
      searched_tags.each do |searched_tag|
        xml.xpath(searched_tag).find do |tag|
          return tag if tag.text.include?(placeholder)
        end
      end
      raise "Placeholder #{placeholder} not found"
    end

    def build_new_tags(variable, placeholder_tag, table_template)
      variable.value_list.map do |value|
        build_tag(value, placeholder_tag, variable.cell_placeholder, table_template)
      end
    end

    def build_tag(value, placeholder_tag, cell_placeholder, table_template)
      if value.is_a?(String)
        new_tag = deep_clone(placeholder_tag)
        new_tag.inner_html = sanitize(value)
        return new_tag
      end

      raise 'Value must be a String or an OpenStruct' unless value.is_a?(OpenStruct)

      raise 'Table template must be provided to generate table' if table_template.nil?

      table_from_template(table_template, value, cell_placeholder)
    end

    def insert_linebreaks_between(tags, placeholder_tag, nb_linebreaks)
      whitespace = whitespace(placeholder_tag, nb_linebreaks)
      tags.map { |tag| [tag, deep_clone(whitespace)] }.flatten[..-2]
    end

    def whitespace(placeholder_tag, nb_linebreaks)
      nb_linebreaks = [0, nb_linebreaks - 2].max # -2 because placeholder_tag generates 2 linebreaks
      new_tag = deep_clone(placeholder_tag)
      if nb_linebreaks.positive?
        nb_linebreaks.times.map { new_tag.inner_html = ODF_LINEBREAK * nb_linebreaks }
      else
        new_tag.children.remove
      end
      new_tag
    end
  end
end
