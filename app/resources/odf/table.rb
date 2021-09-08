# frozen_string_literal: true

module Odf
  module Table
    include Odf::XmlHelpers

    def table_from_template(table_template, table_struct_to_insert, cell_placeholder)
      output_table = deep_clone(table_template)
      ensure_one_cell(output_table)
      generate_table(output_table, table_struct_to_insert, cell_placeholder)
      output_table['table:name'] = ''
      output_table
    end

    private

    def ensure_one_cell(table)
      raise 'Table must have exactly one cell' if table.xpath('.//table:table-cell').size != 1

      raise 'Table must have exactly one row' if table.xpath('.//table:table-row').size != 1
    end

    def generate_table(table, table_to_insert, cell_placeholder)
      generate_columns(table, compute_nb_columns(table_to_insert))
      generate_rows(table, table_to_insert, cell_placeholder)
    end

    def generate_columns(table, nb_columns)
      template_column = get_first('column', table)
      new_columns = (1..nb_columns).map { |_| deep_clone(template_column) }
      new_columns.each { |column| template_column.before(column) }
      template_column.remove
    end

    def generate_rows(table, table_to_insert, cell_placeholder)
      template_row = get_first('row', table)
      rows_to_insert = table_to_insert.rows.map { |row| generate_row(template_row, row, cell_placeholder) }
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

    def generate_row(template_row, row, cell_placeholder)
      new_row = deep_clone(template_row)
      template_cell = get_first('cell', new_row)
      cells_to_insert = row.cells.map { |cell| generate_cell(template_cell, cell, cell_placeholder) }
      cells_to_insert.each { |cell| new_row.add_child(cell) }
      template_cell.remove
      new_row
    end

    def generate_cell(template_cell, cell, cell_placeholder)
      new_cell = deep_clone(template_cell)
      replace_in_xml(new_cell, cell_placeholder, cell.content.text, true)
      new_cell['table:number-rows-spanned'] = cell.rowspan if cell.rowspan.to_i != 1
      new_cell['table:number-columns-spanned'] = cell.colspan if cell.colspan.to_i != 1
      new_cell
    end
  end
end
