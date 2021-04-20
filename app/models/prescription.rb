# frozen_string_literal: true

class Prescription < ApplicationRecord
  belongs_to :user

  def self.from_aps(user)
    where(user_id: user.id).where(alinea_id: nil)
  end
end
