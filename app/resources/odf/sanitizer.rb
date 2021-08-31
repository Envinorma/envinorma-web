# frozen_string_literal: true

module Odf
  module Sanitizer
    def sanitize_odt_xml(txt)
      txt = html_escape(txt)
      odf_linebreak(txt)
    end

    ODF_LINEBREAK = '<text:line-break/>'

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

      txt.to_s.gsub("\n", ODF_LINEBREAK)
    end
  end
end
