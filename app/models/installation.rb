class Installation < ApplicationRecord
  has_many :classements

  validates :name, :date, presence: true
end
