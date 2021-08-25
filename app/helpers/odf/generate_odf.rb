# frozen_string_literal: true

module Odf
  module GenerateOdf
    include Odf::Table
    include Odf::TableTemplate
    include Odf::SectionTemplate

    def generate_doc(prescriptions)
      template_path = File.join(File.dirname(__FILE__), '../../db/templates/template.odt')

      fiche_inspection = ODFReport::Report.new(template_path) do |r|
        insert_data(r, prescriptions, group_by_topics)
      end

      send_doc(fiche_inspection)
    end

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

    # def replace_variables(prescription)
    #   input_filename = 'db/templates/template.odt'
    #   output_filename = 'db/templates/out.odt'
    #   delete_file_if_exists(output_filename)
    #   input_xml = load_content_xml(input_filename)
    #   new_content_xml = input_xml.gsub('[PRESCRIPTION]', prescription.content)
    #   new_content_xml = new_content_xml.gsub('[REF]', prescription.reference)
    #   write_new_document(input_filename, new_content_xml, output_filename)
    # end

    def test
      input_filename = 'db/templates/template.odt'
      output_filename = 'db/templates/out.odt'
      delete_file_if_exists(output_filename)
      # input_xml = load_content_xml(input_filename)
      vars = ['[PRESCRIPTION]', '[REF]']
      values = (1..10).map { |x| ["Content#{x}\nlinebreak\nx < 4\n<html></html>", "reference#{x}.#{x}"] }
      fill_table_in_template(input_filename, output_filename, 'Tableau', vars, values)
      # fill_table(input_xml, 'Tableau', vars, values)
    end

    def test2
      input_filename = 'db/templates/template_with_topics.odt'
      output_filename = 'db/templates/out.odt'
      delete_file_if_exists(output_filename)
      vars = ['[PRESCRIPTION]', '[REF]']
      values = (1..10).map { |x| ["Content#{x}\nlinebreak\nx < 4\n<html></html>", "reference#{x}.#{x}"] }
      input_xml = load_content_xml(input_filename)
      variable_hashes = [{ '[TOPIC]' => 'EAU' }, { '[TOPIC]' => 'FIRE' }, { '[TOPIC]' => 'DECHETS' }]
      # table_variables = [[['Tableau1', vars, values]], [['Tableau1', vars, values]], [['Tableau1', vars, values]]]
      table_variables = [[['Tableau1', vars, values]], [], [['Tableau1', vars, [['ct', 'rf']]]]]
      new_xml = fill_section(input_xml, 'Section', variable_hashes, table_variables)
      write_new_document(input_filename, new_xml, output_filename)
    end

    def test3
      input_filename = 'db/templates/template_with_table.odt'
      output_filename = 'db/templates/out.odt'
      delete_file_if_exists(output_filename)
      input_xml = load_content_xml(input_filename)
      prescriptions = Prescription.all.filter { |p| p.contains_table? }[0, 10]
      var_hashes = prescriptions.map { |p| { '[REFERENCE]' => p.reference.to_s } }
      tables_from_template = prescriptions.map { |_| [] }
      tables = prescriptions.map { |p| [['Tableau', JSON.parse(p.content, object_class: OpenStruct)]] }
      new_xml = fill_section(input_xml, 'Section', var_hashes, tables_from_template, tables)
      write_new_document(input_filename, new_xml, output_filename)
    end

    def fill_table_in_template(template_filename, output_filename, table_name, rows_variables, values)
      input_xml = load_content_xml(template_filename)
      new_xml = fill_table(input_xml, table_name, rows_variables, values)
      write_new_document(template_filename, new_xml, output_filename)
    end
  end
end
