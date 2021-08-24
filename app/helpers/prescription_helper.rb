# frozen_string_literal: true

module PrescriptionHelper
  include TableHelper

  def content_with_slitted_lines(content)
    tag.div do
      content.split("\n").map do |line|
        concat(tag.p(line))
      end
    end
  end

  def html_content(prescription)
    return content_with_slitted_lines(prescription.content) unless prescription.contains_table?

    create_table(JSON.parse(prescription.content, object_class: OpenStruct))
  end
end
