# frozen_string_literal: true

class Prescription < ApplicationRecord
  belongs_to :user
  belongs_to :installation

  def type
    from_am_id.nil? ? 'AP' : 'AM'
  end

  def rank_array
    rank.nil? ? [] : rank.split('.').map(&:to_i)
  end
end
