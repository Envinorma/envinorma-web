# frozen_string_literal: true

module Odf
  module Table
    include Odf::XmlHelpers

    class TableVariables
      attr_reader :name, :struct_to_insert

      def initialize(name, struct_to_insert)
        @name = name
        @struct_to_insert = struct_to_insert
      end
    end

    def insert_table(xml, table_variables)
      table = find_table(xml, table_variables.name)
      ensure_one_cell(table)
      generate_table(table, table_variables.struct_to_insert)
      xml
    end

    CELL_CONTENT = '[CONTENT]'

    private

    def ensure_one_cell(table)
      raise 'Table must have exactly one cell' if table.xpath('.//table:table-cell').size != 1

      raise 'Table must have exactly one row' if table.xpath('.//table:table-row').size != 1
    end

    def generate_table(table, table_to_insert)
      generate_columns(table, compute_nb_columns(table_to_insert))
      generate_rows(table, table_to_insert)
    end

    def generate_columns(table, nb_columns)
      template_column = get_first('column', table)
      new_columns = (1..nb_columns).map { |_| deep_clone(template_column) }
      new_columns.each { |column| template_column.before(column) }
      template_column.remove
    end

    def generate_rows(table, table_to_insert)
      template_row = get_first('row', table)
      rows_to_insert = table_to_insert.rows.map { |row| generate_row(template_row, row) }
      rows_to_insert.each { |row| table.add_child(row) }
      template_row.remove
    end

    def compute_nb_columns(table)
      table.rows.map { |row| row.cells.map { |cell| cell.colspan.to_i }.sum }.max
    end

    def get_first(element, table)
      first_element = table.xpath(".//table:table-#{element}").first

      raise "Table must have at least one #{element}" if first_element.nil?

      first_element
    end

    def generate_row(template_row, row)
      new_row = deep_clone(template_row)
      template_cell = get_first('cell', new_row)
      cells_to_insert = row.cells.map { |cell| generate_cell(template_cell, cell) }
      cells_to_insert.each { |cell| new_row.add_child(cell) }
      template_cell.remove
      new_row
    end

    def generate_cell(template_cell, cell)
      new_cell = deep_clone(template_cell)
      replace_variable(new_cell, CELL_CONTENT, cell.content.text)
      new_cell['table:number-rows-spanned'] = cell.rowspan if cell.rowspan.to_i != 1
      new_cell['table:number-columns-spanned'] = cell.colspan if cell.colspan.to_i != 1
      new_cell
    end
  end
end
