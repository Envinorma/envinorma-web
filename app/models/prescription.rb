# frozen_string_literal: true

class Prescription < ApplicationRecord
  belongs_to :ap
  belongs_to :user
end
