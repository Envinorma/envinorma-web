# frozen_string_literal: true

class ClassementReference < ApplicationRecord
  validates :regime, :rubrique, :description, presence: true
  validates :regime, inclusion: { in: %w[A E D NC], message: 'is not valid' }
end
