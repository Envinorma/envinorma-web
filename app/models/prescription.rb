# frozen_string_literal: true

class Prescription < ApplicationRecord
  # include ActionView::Helpers

  belongs_to :user

  def type
    from_am_id.nil? ? 'AP' : 'AM'
  end

  def self.from_user_and_installation(user)
    # TODO: add installation
    where(user_id: user.id)
  end

  def self.grouped_prescriptions(user)
    group_prescriptions(from_user_and_installation(user))
  end

  def rank_array
    rank.split('.').map(&:to_i)
  end

  def self.group_prescriptions(prescriptions)
    result = {}
    prescriptions.sort_by(&:type).group_by(&:text_reference).each do |text_reference, group|
      result[text_reference] = group.sort_by(&:rank_array).group_by(&:reference)
    end
    result
  end
end
