# frozen_string_literal: true

class ArretesClassement < ApplicationRecord
  belongs_to :arrete
  belongs_to :classement
end
