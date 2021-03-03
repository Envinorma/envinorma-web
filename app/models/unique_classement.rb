# frozen_string_literal: true

class UniqueClassement < ApplicationRecord
  has_many :arretes_unique_classements, dependent: :delete_all
  has_many :arretes, through: :arretes_unique_classements
end
