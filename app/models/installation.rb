class Installation < ApplicationRecord
  has_many :classements
  has_many :arretes

  validates :name, :date, presence: true
end
