# frozen_string_literal: true

class EnrichedArrete < ApplicationRecord
  belongs_to :arrete

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end
end
