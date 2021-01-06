class Classement < ApplicationRecord
  belongs_to :installation
  has_many :arretes_classements, dependent: :delete_all
  has_many :arretes, through: :arretes_classements, dependent: :delete_all

  validates :regime, :rubrique, presence: true
end
