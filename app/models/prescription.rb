# frozen_string_literal: true

class Prescription < ApplicationRecord
  belongs_to :user
  belongs_to :installation

  validates :alinea_id, uniqueness: { scope: %i[installation_id user_id] }, if: :from_am?

  def from_am?
    type == 'AM'
  end

  def type
    from_am_id.nil? ? 'AP' : 'AM'
  end

  def rank_array
    rank.nil? ? [] : rank.split('.').map(&:to_i)
  end

  class << self
    def delete_and_reset_primary_key
      puts 'Deleting existing Prescriptions.'
      Prescription.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Prescription.table_name)
    end
  end
end
