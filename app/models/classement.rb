class Classement < ApplicationRecord
  belongs_to :installation

  validates :rubrique, :regime, :alinea, :installation_id, presence: true
end
