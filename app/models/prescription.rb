# frozen_string_literal: true

class Prescription < ApplicationRecord
  belongs_to :user
  belongs_to :installation

  def self.from(user, installation)
    where(user_id: user.id, installation_id: installation.id)
  end
end
