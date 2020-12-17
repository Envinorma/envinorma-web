class Classement < ApplicationRecord
  belongs_to :installation
  has_many :arretes_classements
  has_many :arretes, through: :arretes_classements
end
