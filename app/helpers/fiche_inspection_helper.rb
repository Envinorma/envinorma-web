# frozen_string_literal: true

module FicheInspectionHelper
  include TopicHelper
  include Odf::GenerateOdf
  include Odf::Table
  include Odf::TableFromRows
  include Odf::Section
  include PrescriptionsGroupingHelper

  def send_fiche_inspection(prescriptions, group_by_topics)
    Tempfile.create('fiche_inspection.odt') do |file|
      generate_odt(file.path, prescriptions, group_by_topics)
      send_fiche(File.open(file.path, 'rb', &:read))
    end
  end

  ANNEXE_SECTION = 'TableSection'
  ANNEXE_TABLEAU = 'TableauAnnexe'
  ANNEXE_INDEX = '[NUMERO_TABLEAU]'
  PRESCRIPTIONS_TABLE = 'TableauPrescriptions'
  PRESCRIPTION_CONTENT = '[CONTENT]'
  PRESCRIPTION_REFERENCE = '[REFERENCE]'
  TOPICS_SECTION = 'TopicSection'
  TOPIC_NAME = '[TOPIC_NAME]'

  private

  def generate_odt(output_file, prescriptions, group_by_topics)
    input_template = template_path(group_by_topics)
    sections, tables_from_rows = prepare_data(prescriptions, group_by_topics)
    fill_template(input_template, output_file, {}, sections, [], tables_from_rows)
  end

  def template_path(group_by_topics)
    template_name = group_by_topics ? 'fiche_inspection_topics' : 'fiche_inspection'
    Rails.root.join("db/templates/#{template_name}.odt")
  end

  def prepare_data(prescriptions, group_by_topics)
    if group_by_topics
      topic_section_variables, tables = prepare_topic_sections(prescriptions)
      tables_in_annexe_section = prepare_tables_in_annexe_section(tables)
      return [[topic_section_variables, tables_in_annexe_section], []]
    end

    rows, tables = prepare_prescription_rows([prescriptions])
    tables_in_annexe_section = prepare_tables_in_annexe_section(tables)
    [[tables_in_annexe_section], rows[0]]
  end

  def prepare_tables_in_annexe_section(tables)
    variables = (1..tables.length).map { |index| { ANNEXE_INDEX => index.to_s } }
    table_variables = tables.map { |table| [Odf::Table::TableVariables.new(ANNEXE_TABLEAU, table)] }
    rows = tables.map { |_| [] }
    Odf::Section::SectionVariables.new(ANNEXE_SECTION, variables, table_variables, rows)
  end

  def prepare_topic_sections(prescriptions)
    topic_groups = group_by_topics(prescriptions)
    variables = topic_groups.map { |topic, _| { TOPIC_NAME => TOPICS[topic] } }
    table_variables = topic_groups.map { |_| [] }
    rows, tables = prepare_prescription_rows(topic_groups.map { |_, groups| groups })
    [Odf::Section::SectionVariables.new(TOPICS_SECTION, variables, table_variables, rows), tables]
  end

  def prepare_prescription_rows(prescription_groups)
    names = [PRESCRIPTION_REFERENCE, PRESCRIPTION_CONTENT]
    all_tables = []
    result = []
    prescription_groups.each do |prescriptions|
      values, tables = merge_prescriptions_with_same_ref(prescriptions, all_tables.length)
      all_tables.push(*tables)
      result << [Odf::TableFromRows::TableFromRowsVariables.new(PRESCRIPTIONS_TABLE, names, values)]
    end
    [result, all_tables]
  end

  def merge_prescriptions_with_same_ref(prescriptions, table_index)
    groups = []
    tables = []
    sort_and_group_by_text(prescriptions).each do |text_reference, group|
      group.each do |section_reference, subgroup|
        contents = subgroup.map do |prescription|
          if prescription.is_table?
            table_index += 1
            tables << prescription.table
            "Voir tableau #{table_index}"
          else
            prescription.content
          end
        end
        groups << ["#{text_reference} - #{section_reference}", contents.join("\n\n")]
      end
    end
    [groups, tables]
  end

  def send_fiche(data)
    send_data(data, type: 'application/vnd.oasis.opendocument.text', disposition: 'inline',
                    filename: 'fiche_inspection.odt')
  end
end
