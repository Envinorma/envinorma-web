# frozen_string_literal: true

class Section < ApplicationRecord
  belongs_to :arrete

  validates :rank, :level, :active, :modified, :arrete_id, presence: true
end
