class Arrete < ApplicationRecord
  has_many :arretes_classements, dependent: :delete_all
  has_many :classements, through: :arretes_classements
  has_many :enriched_arretes, dependent: :destroy

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end
end
