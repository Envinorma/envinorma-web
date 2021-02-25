# frozen_string_literal: true

class AP < ApplicationRecord
  belongs_to :installation

  validates :url, :installation_id, presence: true
end
