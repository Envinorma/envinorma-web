# frozen_string_literal: true

class User < ApplicationRecord
  has_many :installations, dependent: :destroy
  has_many :prescriptions, dependent: :destroy

  def already_duplicated_installation?(installation)
    present? && installations.pluck(:duplicated_from_id).include?(installation.id)
  end

  def retrieve_duplicated_installation(installation)
    installations.where(duplicated_from_id: installation.id).first
  end
end
