# frozen_string_literal: true

class UniqueClassement < ApplicationRecord
  has_many :arretes_unique_classements, dependent: :delete_all
  has_many :arretes, through: :arretes_unique_classements

  validates :rubrique, :regime, presence: true
  validates :regime, inclusion: { in: %w[A E D], message: 'is invalid' }
  validates :rubrique, format: { with: /\A[1-4][0-9]{3}\z/,
                                 message: 'must be made of 4 digit and start with 1, 2, 3 or 4.' }
end
