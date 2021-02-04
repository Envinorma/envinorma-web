class Installation < ApplicationRecord
  has_many :classements, dependent: :destroy
  accepts_nested_attributes_for :classements, allow_destroy: true

  has_many :arretes, through: :classements
  has_many :APs
  belongs_to :user, optional: true

  validates :name, presence: true

  scope :not_attached_to_user, -> { where(user: nil) }
end
