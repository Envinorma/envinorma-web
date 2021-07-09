# frozen_string_literal: true

module FicheInspectionHelper
  include TopicHelper

  def generate_doc(prescriptions, group_by_topics)
    template_name = group_by_topics ? 'template_with_topics' : 'template'
    template_path = File.join(File.dirname(__FILE__), "../../db/templates/#{template_name}.odt")

    fiche_inspection = ODFReport::Report.new(template_path) do |r|
      insert_data(r, prescriptions, group_by_topics)
    end

    send_doc(fiche_inspection)
  end

  private

  def insert_data(report, prescriptions, group_by_topics)
    return insert_prescriptions_table(report, prescriptions) unless group_by_topics

    insert_topic_sections_and_prescriptions(report, prescriptions)
  end

  def insert_prescriptions_table(report, prescriptions)
    report.add_table('Tableau', prescriptions, header: true) do |t|
      insert_prescriptions_row(t)
    end
  end

  def insert_topic_sections_and_prescriptions(report, prescriptions)
    report.add_section('Section', prescriptions) do |s|
      s.add_field(:topic) { |topic_group| TOPICS[topic_group[:topic]] }
      s.add_table('Tableau1', :groups, header: true) do |t|
        insert_prescriptions_row(t)
      end
    end
  end

  def insert_prescriptions_row(table)
    table.add_column(:ref, :full_reference)
    table.add_column(:prescription, :content)
  end

  def send_doc(fiche_inspection)
    send_data fiche_inspection.generate,
              type: 'application/vnd.oasis.opendocument.text',
              disposition: 'inline',
              filename: 'fiche_inspection.odt'
  end
end
