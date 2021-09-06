# frozen_string_literal: true

module TableHelper
  def extract_cell_content(cell)
    # Extracts the content of a cell, replacing text line breaks with HTML line breaks
    cell['content']['text'].to_s.gsub(/\n/, '<br/>').html_safe # rubocop:disable Rails/OutputSafety
  end

  def create_row(row)
    tag.tr do
      cell_tag = row['is_header'] ? :th : :td
      row['cells'].map do |cell|
        colspan = cell['colspan'].to_s
        rowspan = cell['rowspan'].to_s
        concat(content_tag(cell_tag, extract_cell_content(cell), colspan: colspan, rowspan: rowspan))
      end
    end
  end

  def create_table(table)
    tag.table(class: 'table table-bordered') do
      table['rows'].map do |row|
        concat(create_row(row))
      end
    end
  end
end
