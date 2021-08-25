# frozen_string_literal: true

module Odf
  module Section
    include Odf::Table
    include Odf::TableFromRows
    include Odf::XmlHelpers

    class SectionVariables
      attr_reader :name, :variables_hashes, :tables, :tables_from_rows

      def initialize(name, variables_hashes, tables, tables_from_rows)
        ensure_same_length([variables_hashes, tables, tables_from_rows],
                           'All input lists must have same length')
        @name = name
        @variables_hashes = variables_hashes
        @tables = tables
        @tables_from_rows = tables_from_rows
      end

      def ensure_same_length(tables, error_message)
        raise(ArgumentError, error_message) if tables.map(&:length).uniq.length != 1
      end
    end

    def fill_section(xml, section_variables)
      template_section = find_section(xml, section_variables.name)
      new_sections = generate_sections_from_template(template_section, section_variables)
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

    def generate_sections_from_template(template_section, section_variables)
      objects = section_variables.variables_hashes.zip(section_variables.tables_from_rows, section_variables.tables)
      objects.map do |variables_hash, table_from_rows, tables|
        generate_section_from_template(template_section, variables_hash, table_from_rows, tables)
      end
    end

    def generate_section_from_template(template_section, variables_hash, table_from_rows, tables)
      new_section = deep_clone(template_section)
      replace_variables(new_section, variables_hash)
      table_from_rows.each { |table_from_row| fill_table_rows(new_section, table_from_row) }
      tables.each { |table| insert_table(new_section, table) }
      new_section
    end
  end
end
