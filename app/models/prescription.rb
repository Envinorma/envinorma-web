# frozen_string_literal: true

class Prescription < ApplicationRecord
  # include ActionView::Helpers

  belongs_to :user

  def type
    from_am_id.nil? ? 'AP' : 'AM'
  end

  def self.from_user(user)
    group_prescriptions(where(user_id: user.id))
  end

  def self.from_aps(user)
    where(user_id: user.id).where(alinea_id: nil)
  end

  def self.group_prescriptions(prescriptions)
    result = {}
    prescriptions.sort_by(&:type).group_by(&:text_reference).each do |text_reference, group|
      result[text_reference] = group.sort_by(&:rank).group_by(&:reference)
    end
    result
  end
end
