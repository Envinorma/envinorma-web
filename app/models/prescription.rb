# frozen_string_literal: true

class Prescription < ApplicationRecord
  # include ActionView::Helpers

  belongs_to :user
  belongs_to :installation

  def self.from(user, installation)
    where(user_id: user.id, installation_id: installation.id)
  end

  def type
    from_am_id.nil? ? 'AP' : 'AM'
  end

  def self.grouped_prescriptions(user, installation)
    group_prescriptions(from(user, installation))
  end

  def rank_array
    rank.nil? ? [] : rank.split('.').map(&:to_i)
  end

  def self.group_prescriptions(prescriptions)
    result = {}
    prescriptions.sort_by(&:type).group_by(&:text_reference).each do |text_reference, group|
      result[text_reference] = group.sort_by(&:rank_array).group_by(&:reference)
    end
    result
  end
end
