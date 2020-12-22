class Classement < ApplicationRecord
  belongs_to :installation
  has_many :arretes_classements, dependent: :destroy
  has_many :arretes, through: :arretes_classements, dependent: :destroy
end
