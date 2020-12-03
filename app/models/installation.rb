class Installation < ApplicationRecord
  has_many :classements
  has_many :arretes, through: :classements

  validates :name, presence: true
end
