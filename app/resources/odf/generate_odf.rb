# frozen_string_literal: true

require 'zip'

module Odf
  module GenerateOdf
    include Odf::TableFromRows
    include Odf::Section
    include Odf::XmlHelpers

    CONTENT_NAME = 'content.xml'

    class OdfGenerator
      include Odf::TableFromRows
      include Odf::Section
      include Odf::GenerateOdf

      attr_reader :section_variables, :table_from_rows_variables

      def initialize(section_variables, table_from_rows_variables)
        @section_variables = section_variables
        @table_from_rows_variables = table_from_rows_variables
      end

      def template_table_names
        in_sections = section_variables.map(&:template_table_names).flatten
        in_tables = table_from_rows_variables.map(&:template_table_names).flatten
        (in_sections + in_tables).uniq.filter(&:present?)
      end

      def fill_template(input_file, output_file)
        xml = Nokogiri::XML(load_content_xml(input_file))
        table_templates = template_table_names.index_with { |name| find_table(xml, name) }
        section_variables.each { |section| fill_section(xml, section, table_templates) }
        table_from_rows_variables.each { |table_rows| fill_table_rows(xml, table_rows, table_templates) }
        remove_template_tables(xml, table_templates.keys)
        write_new_document(input_file, xml.to_s, output_file)
      end
    end

    def remove_template_tables(xml, table_names)
      remove_tables(xml, table_names)
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

    private

    def remove_tables(xml, table_names)
      table_names.each do |table_name|
        xml.xpath("//table:table[@table:name='#{table_name}']").remove
      end
    end

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
  end
end
