# frozen_string_literal: true

class AlineaStore < ApplicationRecord
  validates :section_id, :am_id, :index_in_section, :section_rank, :topic, presence: true
  validates :is_table, inclusion: { in: [true, false] }
end
