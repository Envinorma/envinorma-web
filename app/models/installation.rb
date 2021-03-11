# frozen_string_literal: true

class Installation < ApplicationRecord
  has_many :classements, dependent: :destroy
  accepts_nested_attributes_for :classements, allow_destroy: true

  has_many :APs, dependent: :destroy
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :regime, inclusion: { in: %w[A E], message: 'not a valid installation regime' }
  validates :s3ic_id, format: { with: /\A([0-9]{4}\.[0-9]{5})\z/,
                                message: 'check s3ic_id format' }

  scope :not_attached_to_user, -> { where(user: nil) }

  def self.recreate!(installations_list)
    Installation.destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!(Installation.table_name)

    installations_list.each do |installation|
      Installation.create(
        name: installation['name'],
        s3ic_id: installation['s3ic_id'],
        region: installation['region'],
        department: installation['department'],
        zipcode: installation['code_postal'],
        city: installation['city'],
        last_inspection: installation['last_inspection']&.to_date,
        regime: installation['regime'],
        seveso: installation['seveso'],
        state: installation['active']
      )
    end
    puts 'Installations are seeded'
  end
end
