# frozen_string_literal: true

module OdfHelper
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

  def merge_prescriptions_with_same_ref(prescriptions)
    prescriptions_joined_by_ref = {}
    PrescriptionsGroupingHelper.sort_and_group(prescriptions).each do |text_reference, group|
      group.each do |section_reference, subgroup|
        content = compute_cell_content(subgroup)
        full_reference = "#{text_reference} - #{section_reference}"
        prescriptions_joined_by_ref[full_reference] = content
      end
    end
    prescriptions_joined_by_ref
  end
end
