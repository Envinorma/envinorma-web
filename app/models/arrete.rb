class Arrete < ApplicationRecord
  belongs_to :installation

  validates :name, :installation_id, presence: true

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end
end
