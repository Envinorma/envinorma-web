# frozen_string_literal: true

module Odf
  module TableFromRows
    include Odf::XmlHelpers

    class TableFromRowsVariables
      attr_reader :name, :variable_names, :variable_values

      def initialize(name, variable_names, variable_values)
        @name = name
        @variable_names = variable_names
        @variable_values = variable_values
      end
    end

    def fill_table_rows(xml, table_row_variables)
      table = find_table(xml, table_row_variables.name)
      template_row = find_template_row(table, table_row_variables.variable_names)
      rows_to_add = generate_rows_from_template(
        template_row, table_row_variables.variable_names, table_row_variables.variable_values
      )
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
