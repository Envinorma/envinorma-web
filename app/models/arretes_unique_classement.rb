# frozen_string_literal: true

class ArretesUniqueClassement < ApplicationRecord
  belongs_to :arrete
  belongs_to :unique_classement
end
