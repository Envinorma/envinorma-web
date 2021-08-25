# frozen_string_literal: true

module Odf
  module GenerateOdf
    include Odf::Table
    include Odf::TableFromRows
    include Odf::Section

    CONTENT_NAME = 'content.xml'

    def zip_files(base_names, directory, zip_filename)
      Zip::File.open(zip_filename, create: true) do |zipfile|
        base_names.each do |base_name|
          zipfile.add(base_name, File.join(directory, base_name))
        end
      end
    end

    def unzip_file(zip_filename, directory)
      names = []
      Zip::File.open(zip_filename) do |zipfile|
        zipfile.each do |entry|
          names << entry.name
          path = File.join(directory, entry.name)
          FileUtils.mkdir_p(File.dirname(path))
          zipfile.extract(entry, path) unless File.exist?(path)
        end
      end
      names
    end

    def write_new_document(input_filename, new_content_xml, new_filename)
      Dir.mktmpdir do |tmp_dir|
        names = unzip_file(input_filename, tmp_dir)
        File.open(File.join(tmp_dir, CONTENT_NAME), 'wb') do |f|
          f.write(new_content_xml.encode(Encoding::UTF_8))
        end
        zip_files(names, tmp_dir, new_filename)
      end
    end

    def load_content_xml(filename)
      Zip::File.open(filename) do |zipfile|
        zipfile.read(CONTENT_NAME).force_encoding(Encoding::UTF_8)
      end
    end

    def delete_file_if_exists(filename)
      File.delete(filename) if File.exist?(filename)
    end

    # rubocop:disable Metrics/ParameterLists
    def fill_template(input_file, output_file, simple_variables, section_variables, table_variables,
                      table_from_rows_variables)
      xml = Nokogiri::XML(load_content_xml(input_file))
      replace_variables(xml, simple_variables)
      section_variables.each { |section| fill_section(xml, section) }
      table_variables.each { |table| fill_table(xml, table) }
      table_from_rows_variables.each { |table_rows| fill_table_rows(xml, table_rows) }
      write_new_document(input_file, xml.to_s, output_file)
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
