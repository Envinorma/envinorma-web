# frozen_string_literal: true

class Section < ApplicationRecord
  belongs_to :arrete
  has_many :alineas

  validates :rank, :level, :active, :modified, :arrete_id, presence: true
end
