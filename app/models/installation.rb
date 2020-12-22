class Installation < ApplicationRecord
  has_many :classements
  has_many :arretes, through: :classements
  belongs_to :user, optional: true

  validates :name, presence: true
end
