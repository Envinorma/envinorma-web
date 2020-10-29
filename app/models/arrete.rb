class Arrete < ApplicationRecord
  belongs_to :installation

  validates :name, :installation_id, presence: true
end
