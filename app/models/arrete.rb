class Arrete < ApplicationRecord
  has_many :classements
  has_many :installations, through: :classements

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end
end
