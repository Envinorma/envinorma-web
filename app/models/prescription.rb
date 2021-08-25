# frozen_string_literal: true

class Prescription < ApplicationRecord
  belongs_to :user
  belongs_to :installation

  validates :alinea_id, uniqueness: { scope: %i[installation_id user_id] }, if: :from_am?

  def from_am?
    type == 'AM'
  end

  def type
    from_am_id.nil? ? 'AP' : 'AM'
  end

  def rank_array
    rank.nil? ? [] : rank.split('.').map(&:to_i)
  end

  def table
    raise 'Cannot read table' unless is_table?

    JSON.parse(content, object_class: OpenStruct)
  end
end
