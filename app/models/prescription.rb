# frozen_string_literal: true

class Prescription < ApplicationRecord
  belongs_to :ap
  belongs_to :user

  validates :reference, :content, :ap_id, :user_id, presence: true
end
