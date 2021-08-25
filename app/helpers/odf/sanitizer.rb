# frozen_string_literal: true

module Odf
  module Sanitizer
    def sanitize(txt)
      txt = html_escape(txt)
      odf_linebreak(txt)
    end

    private

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
  end
end
