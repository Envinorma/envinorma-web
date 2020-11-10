module ApplicationHelper
  def transform_for_id string
    I18n.transliterate(string).delete ' '
  end
end
