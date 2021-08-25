# frozen_string_literal: true

module Odf
  module SectionTemplate
    include Odf::Table
    include Odf::TableTemplate
    include Odf::XmlHelpers

    def fill_section(xml_string, section_name, variables_hashes, table_templates, tables_to_insert)
      ensure_same_length([variables_hashes, table_templates, tables_to_insert],
                         'There must be as many variables hashes as tables')
      xml = Nokogiri::XML(xml_string)
      template_section = find_section(xml, section_name)
      new_sections = generate_sections_from_template(
        template_section, variables_hashes, table_templates, tables_to_insert)
      new_sections.each { |section| template_section.parent.add_child(section) }
      template_section.remove
      xml.to_s
    end

    private

    def ensure_same_length(tables, error_message)
      raise(ArgumentError, error_message) if tables.map(&:length).uniq.length != 1
    end

    def find_section(xml, section_name)
      results = xml.xpath("//text:section[@text:name='#{section_name}']")

      raise "Section #{section_name} not found" if results.empty?

      raise "Multiple sections called #{section_name} found" if results.size > 1

      results.first
    end

    def generate_sections_from_template(template_section, variables_hashes,
                                        table_variables_lists, tables_to_insert)
      objects = variables_hashes.zip(table_variables_lists, tables_to_insert)
      objects.map do |variables_hash, table_variables, tables|
        new_section = deep_clone(template_section)
        replace_variables(new_section, variables_hash)
        fill_table_templates(new_section, table_variables)
        insert_tables(new_section, tables)
        new_section
      end
    end

    def fill_table_templates(section, table_variables)
      table_variables.each do |table_name, variable_names, variable_values|
        fill_table_in_xml(section, table_name, variable_names, variable_values)
      end
    end

    def insert_tables(section, tables)
      tables.each { |table_name, table| insert_table_in_xml(section, table_name, table) }
    end
  end
end
