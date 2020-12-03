class Classement < ApplicationRecord
  belongs_to :installation
  belongs_to :arrete

  validates :rubrique, :regime, presence: true
end
