module ODFReport
  class Field
    def replace!(content, data_item = nil)

      txt = content.inner_html

      txt.gsub!(to_placeholder, @data_source.value)

      content.inner_html = txt

    end
  end
end
