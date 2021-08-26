# frozen_string_literal: true

module Odf
  module TableFromRows
    include Odf::Variables
    include Odf::XmlHelpers

    class TableRows
      attr_reader :table_name, :row_variables

      def initialize(table_name, row_variables)
        check_row_variables(row_variables)
        @table_name = table_name
        @row_variables = row_variables
      end

      def check_row_variables(row_variables)
        raise 'No row variables given' if row_variables.empty?

        # Check that all rows have the same placeholders
        placeholder_lists = row_variables.map { |variables| variables.map(&:placeholder) }
        raise 'Not all rows have the same placeholders' if placeholder_lists.uniq.size > 1
      end

      def variable_placeholders
        @row_variables[0].map(&:placeholder)
      end

      def template_table_names
        row_variables.map { |vars| vars.map(&:template_table_name) }.flatten.uniq
      end
    end

    def fill_table_rows(xml, table_rows, table_templates)
      table = find_table(xml, table_rows.table_name)
      template_row = find_template_row(table, table_rows.variable_placeholders)
      rows_to_add = generate_rows_from_template(template_row, table_rows.row_variables, table_templates)
      rows_to_add.each { |row| table.add_child(row) }
      template_row.remove
      xml
    end

    private

    def generate_rows_from_template(template_row, rows, table_templates)
      rows.map { |variables| generate_row_from_template(template_row, variables, table_templates) }
    end

    def generate_row_from_template(template_row, variables, table_templates)
      row = deep_clone(template_row)
      replace_variables(row, variables, table_templates)
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
