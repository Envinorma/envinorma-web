# frozen_string_literal: true

module FicheInspectionHelper
  include TopicHelper
  include Odf::GenerateOdf
  include Odf::Section
  include Odf::TableFromRows
  include Odf::Variables
  include PrescriptionsGroupingHelper

  def send_fiche_inspection(prescriptions, group_by_topics)
    Tempfile.create('fiche_inspection.odt') do |file|
      generate_odt(file.path, prescriptions, group_by_topics)
      send_fiche(File.open(file.path, 'rb', &:read))
    end
  end

  TABLE_TEMPLATE = 'TableTemplate'
  TABLE_TEMPLATE_CELL = '[TABLE_TEMPLATE_CELL]'
  PRESCRIPTIONS_TABLE = 'TableauPrescriptions'
  PRESCRIPTION_CONTENT = '[CONTENT]'
  PRESCRIPTION_REFERENCE = '[REFERENCE]'
  TOPICS_SECTION = 'TopicSection'
  TOPIC_NAME = '[TOPIC_NAME]'

  def generate_odt(output_file, prescriptions, group_by_topics)
    input_template = template_path(group_by_topics)
    sections = group_by_topics ? prepare_topic_sections(prescriptions) : []
    tables_from_rows = group_by_topics ? [] : prepare_prescription_rows([prescriptions])[0]
    generator = Odf::GenerateOdf::OdfGenerator.new(sections, tables_from_rows)
    generator.fill_template(input_template, output_file)
  end

  private

  def template_path(group_by_topics)
    template_name = group_by_topics ? 'fiche_inspection_topics' : 'fiche_inspection'
    Rails.root.join("db/templates/#{template_name}.odt")
  end

  def prepare_topic_sections(prescriptions)
    topic_groups = group_by_topics(prescriptions)
    variables = topic_groups.map do |topic, _|
      [Odf::Variables::Variable.new(TOPIC_NAME, [TOPICS[topic]])]
    end
    rows = prepare_prescription_rows(topic_groups.map { |_, groups| groups })
    [Odf::Section::SectionVariables.new(TOPICS_SECTION, variables, rows)]
  end

  def prepare_prescription_rows(prescription_groups)
    result = []
    prescription_groups.each do |prescriptions|
      values = merge_prescriptions_with_same_ref(prescriptions)
      variables = values.map do |ref, contents|
        [Odf::Variables::Variable.new(PRESCRIPTION_REFERENCE, [ref]),
         Odf::Variables::Variable.new(PRESCRIPTION_CONTENT, contents, 2, TABLE_TEMPLATE, TABLE_TEMPLATE_CELL)]
      end
      result << [Odf::TableFromRows::TableRows.new(PRESCRIPTIONS_TABLE, variables)]
    end
    result
  end

  def merge_prescriptions_with_same_ref(prescriptions)
    groups = []
    sort_and_group_by_text(prescriptions).each do |text_reference, group|
      group.each do |section_reference, subgroup|
        contents = subgroup.map { |presc| presc.is_table? ? presc.table : presc.content }
        groups << ["#{text_reference} - #{section_reference}", contents]
      end
    end
    groups
  end

  def send_fiche(data)
    send_data(data, type: 'application/vnd.oasis.opendocument.text', disposition: 'inline',
                    filename: 'fiche_inspection.odt')
  end
end
