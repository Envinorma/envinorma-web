# frozen_string_literal: true

class Alinea < ApplicationRecord
  belongs_to :section

  validates :rank, :active, :section_id, presence: true
end
