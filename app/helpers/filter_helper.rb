# frozen_string_literal: true

module FilterHelper
  def self.sort_and_group(prescriptions)
    result = {}
    prescriptions.sort_by { |x| [x.type, x.created_at] }.group_by(&:text_reference).each do |text_reference, group|
      result[text_reference] = group.sort_by(&:rank_array).group_by(&:reference)
    end
    result
  end
end
