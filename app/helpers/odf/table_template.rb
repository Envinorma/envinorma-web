# frozen_string_literal: true

module Odf
  module TableTemplate
    include Odf::XmlHelpers

    def fill_table(xml_string, table_name, variable_names, variable_values)
      fill_table_in_xml(Nokogiri::XML(xml_string), table_name, variable_names, variable_values).to_s
    end

    def fill_table_in_xml(xml, table_name, variable_names, variable_values)
      table = find_table(xml, table_name)
      template_row = find_template_row(table, variable_names)
      rows_to_add = generate_rows_from_template(template_row, variable_names, variable_values)
      rows_to_add.each { |row| table.add_child(row) }
      template_row.remove
      xml
    end

    private

    def generate_rows_from_template(template_row, variable_names, variable_values)
      variable_values.map { |values| generate_row_from_template(template_row, variable_names, values) }
    end

    def generate_row_from_template(template_row, variable_names, variable_values)
      row = deep_clone(template_row)
      variable_hash = variable_names.zip(variable_values).to_h
      replace_variables(row, variable_hash)
      row
    end

    def find_table(xml, table_name)
      results = xml.xpath("//table:table[@table:name='#{table_name}']")

      raise "Table #{table_name} not found" if results.empty?

      raise "Multiple tables #{table_name} found" if results.size > 1

      results.first
    end

    def find_template_row(table, variable_names)
      # Template row is the first row containing all variable names
      table.xpath('//table:table-row').each do |row|
        row_str = row.to_s
        return row if variable_names.map { |name| row_str.include?(name) }.all?
      end
      raise "No row containing all variables #{variable_names} found"
    end
  end
end
