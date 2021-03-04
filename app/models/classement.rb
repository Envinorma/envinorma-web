# frozen_string_literal: true

class Classement < ApplicationRecord
  belongs_to :installation

  validates :regime, :rubrique, presence: true
end
