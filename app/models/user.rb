# frozen_string_literal: true

class User < ApplicationRecord
  has_many :installations, dependent: :destroy
  has_many :prescriptions, dependent: :destroy

  def prescription_checked?(alinea_id)
    prescriptions.map(&:alinea_id).include?(alinea_id)
  end
end
