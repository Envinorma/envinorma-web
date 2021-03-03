# frozen_string_literal: true

class Arrete < ApplicationRecord
  has_many :arretes_unique_classements, dependent: :delete_all
  has_many :unique_classements, through: :arretes_unique_classements
  has_many :enriched_arretes, dependent: :destroy

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end
end
