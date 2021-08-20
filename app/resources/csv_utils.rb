# frozen_string_literal: true

class CsvUtils
  def self.read_column(file, column_name)
    column_values = []
    batch_generator = CSV.foreach(file, headers: true).each_slice(1000)
    batch_generator.each do |batch|
      column_values += batch.map { |row| row[column_name] }
    end
    column_values
  end
end
