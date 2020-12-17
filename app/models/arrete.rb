class Arrete < ApplicationRecord
  has_many :arretes_classements
  has_many :classements, through: :arretes_classements

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end
end
