class Installation < ApplicationRecord
  has_many :classements
  has_many :arretes

  validates :name, presence: true
end
