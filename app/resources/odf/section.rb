# frozen_string_literal: true

module Odf
  module Section
    include Odf::TableFromRows
    include Odf::Variables
    include Odf::XmlHelpers

    class SectionVariables
      attr_reader :name, :variables, :tables_from_rows

      def initialize(name, variables, tables_from_rows)
        ensure_same_length([variables, tables_from_rows], 'All input lists must have same length')
        @name = name
        @variables = variables
        @tables_from_rows = tables_from_rows
      end

      def ensure_same_length(tables, error_message)
        raise(ArgumentError, error_message) if tables.map(&:length).uniq.length != 1
      end

      def template_table_names
        in_variables = variables.map { |vars| vars.map(&:template_table_name) }.flatten
        in_tables = tables_from_rows.map { |tables| tables.map(&:template_table_names) }.flatten
        (in_variables + in_tables).uniq
      end
    end

    def fill_section(xml, section_variables, table_templates)
      template_section = find_section(xml, section_variables.name)
      new_sections = generate_sections_from_template(template_section, section_variables, table_templates)
      new_sections.each { |sec| template_section.parent.add_child(sec) }
      template_section.remove
      xml
    end

    private

    def find_section(xml, section_name)
      results = xml.xpath("//text:section[@text:name='#{section_name}']")

      raise "Section #{section_name} not found" if results.empty?

      raise "Multiple sections called #{section_name} found" if results.size > 1

      results.first
    end

    def generate_sections_from_template(template_section, section_variables, table_templates)
      section_variables.variables.zip(section_variables.tables_from_rows).map do |variables, table_from_rows|
        generate_section_from_template(template_section, variables, table_from_rows, table_templates)
      end
    end

    def generate_section_from_template(template_section, variables, table_from_rows, table_templates)
      new_section = deep_clone(template_section)
      replace_variables(new_section, variables, table_templates)
      table_from_rows.each { |table_from_row| fill_table_rows(new_section, table_from_row, table_templates) }
      new_section
    end
  end
end
