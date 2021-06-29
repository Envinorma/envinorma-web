# frozen_string_literal: true

module OdfHelper
  include PrescriptionsGroupingHelper

  def merge_prescriptions(prescriptions, group_by_topics)
    if group_by_topics

      return group_by_topics(prescriptions).map do |topic, topic_prescriptions|
        { topic: topic, groups: merge_prescriptions_with_same_ref(topic_prescriptions) }
      end
    end
    merge_prescriptions_with_same_ref(prescriptions)
  end

  def merge_prescriptions_with_same_ref(prescriptions)
    prescriptions_joined_by_ref = []
    sort_and_group_by_text(prescriptions).each do |text_reference, group|
      group.each do |section_reference, subgroup|
        prescriptions_joined_by_ref << {
          content: compute_cell_content(subgroup),
          full_reference: "#{text_reference} - #{section_reference}"
        }
      end
    end
    prescriptions_joined_by_ref
  end

  HTML_ESCAPE = {
    '&' => '&amp;',
    '>' => '&gt;',
    '<' => '&lt;',
    '"' => '&quot;'
  }.freeze

  def html_escape(txt)
    return '' unless txt

    txt.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
  end

  def odf_linebreak(txt)
    return '' unless txt

    txt.to_s.gsub("\n", '<text:line-break/>')
  end

  def sanitize(txt)
    txt = html_escape(txt)
    odf_linebreak(txt)
  end

  def compute_cell_content(prescriptions)
    ordered_prescriptions = prescriptions.map!(&:content)
    ordered_prescriptions.map { |x| sanitize(x) }.join('<text:line-break/><text:line-break/>')
  end
end
