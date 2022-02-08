# frozen_string_literal: true

module FicheInspectionHelper
  include TopicHelper
  include Odf::GenerateOdf
  include Odf::Section
  include Odf::TableFromRows
  include Odf::Variables
  include PrescriptionsGroupingHelper

  def send_fiche_inspection(prescriptions, group_by_topics:, gun_env:)
    Tempfile.create do |file|
      if gun_env
        output_filename = 'fiche_GUN.ods'
        generate_gun_env_ods(file.path, prescriptions)
      else
        output_filename = 'fiche_inspection.odt'
        generate_envinorma_odt(file.path, prescriptions, group_by_topics)
      end
      send_fiche(File.binread(file.path), output_filename)
    end
  end

  TABLE_TEMPLATE = 'TableTemplate'
  TABLE_TEMPLATE_CELL = '[TABLE_TEMPLATE_CELL]'
  PRESCRIPTIONS_TABLE = 'TableauPrescriptions'
  PRESCRIPTION_CONTENT = '[CONTENT]'
  PRESCRIPTION_REFERENCE = '[REFERENCE]'
  TOPICS_SECTION = 'TopicSection'
  TOPIC_NAME = '[TOPIC_NAME]'

  def generate_envinorma_odt(output_file, prescriptions, group_by_topics)
    input_template = template_path(group_by_topics)
    sections = group_by_topics && !prescriptions.empty? ? prepare_topic_sections(prescriptions) : []
    tables_from_rows = group_by_topics || prescriptions.empty? ? [] : prepare_prescription_rows([prescriptions])[0]
    generate_open_document_file(sections, tables_from_rows, input_template, output_file)
  end

  def generate_gun_env_ods(output_file, prescriptions)
    input_template = TEMPLATES_FOLDER.join('gun_env_template_v2.ods')
    tables = prescriptions.empty? ? [] : [prepare_gun_env_rows(prescriptions)]
    generate_open_document_file([], tables, input_template, output_file)
  end

  private

  def generate_open_document_file(sections, tables_from_rows, input_file, output_file)
    generator = Odf::GenerateOdf::OdfGenerator.new(sections, tables_from_rows)
    generator.fill_template(input_file, output_file)
  end

  TEMPLATES_FOLDER = Rails.root.join('db/templates')

  def template_path(group_by_topics)
    template_name = group_by_topics ? 'fiche_inspection_topics' : 'fiche_inspection'
    TEMPLATES_FOLDER.join("#{template_name}.odt")
  end

  def prepare_topic_sections(prescriptions)
    topic_groups = group_by_topics(prescriptions)
    variables = topic_groups.map { |topic, _| [simple_variable(TOPIC_NAME, TOPICS[topic])] }
    rows = prepare_prescription_rows(topic_groups.map { |_, groups| groups })
    [Odf::Section::SectionVariables.new(TOPICS_SECTION, variables, rows)]
  end

  def prepare_prescription_rows(prescription_groups)
    result = []
    prescription_groups.each do |prescriptions|
      values = merge_prescriptions_having_same_ref(prescriptions)
      variables = values.map do |ref, contents|
        [simple_variable(PRESCRIPTION_REFERENCE, ref),
         Odf::Variables::Variable.new(PRESCRIPTION_CONTENT, contents, 2, TABLE_TEMPLATE, TABLE_TEMPLATE_CELL)]
      end
      result << [Odf::TableFromRows::TableRows.new(PRESCRIPTIONS_TABLE, variables)]
    end
    result
  end

  def prepare_gun_env_rows(prescriptions)
    variables = sort_and_group(prescriptions).values.map(&:values).flatten(1).map do |group|
      prepare_gun_env_variables_mapping(group).map { |k, v| simple_variable(k, v) }
    end
    Odf::TableFromRows::TableRows.new('PDC', variables)
  end

  def prepare_gun_env_variables_mapping(prescriptions)
    prescription = prescriptions.first
    content = prescriptions.map(&:human_readable_content).join("\n\n")
    text_date = prescription.text_date
    {
      '[NOM]' => prescription.name.nil? ? '' : prescription.name.truncate(70),
      '[SOURCE_TYPE]' => prescription.human_type,
      '[DATE_AAAA-MM-JJ]' => text_date.nil? ? '' : text_date.strftime('%Y-%m-%d'),
      '[DATE_JJ/MM/AAAA]' => text_date.nil? ? '' : text_date.strftime('%d/%m/%Y'),
      '[ARTICLE]' => prescription.reference_number,
      '[THEME]' => '',
      '[SOUS_THEME]' => '',
      '[PRESCRIPTION]' => content,
      '[NOTES]' => ''
    }
  end

  def simple_variable(placeholder, value)
    Odf::Variables::Variable.new(placeholder, [value])
  end

  def merge_prescriptions_having_same_ref(prescriptions)
    sort_and_group(prescriptions).map do |text_reference, group|
      group.map do |section_reference, subgroup|
        contents = subgroup.map { |presc| presc.is_table? ? presc.table : presc.content }
        ["#{text_reference} - #{section_reference}", contents]
      end
    end.flatten(1)
  end

  def send_fiche(data, filename)
    send_data(data, type: 'application/vnd.oasis.opendocument.text', disposition: 'inline',
                    filename: filename)
  end
end
