# frozen_string_literal: true

class Installation < ApplicationRecord
  has_many :classements, dependent: :destroy
  accepts_nested_attributes_for :classements, allow_destroy: true

  has_many :APs, dependent: :destroy
  has_many :prescriptions, dependent: :destroy
  belongs_to :user, optional: true

  validates :name, :s3ic_id, presence: true
  validates :s3ic_id, format: { with: /\A([0-9]{4}\.[0-9]{5})\z/,
                                message: 'check s3ic_id format' }

  scope :not_attached_to_user, -> { where(user: nil) }

  def retrieve_aps
    if duplicated_from_id?
      Installation.find(duplicated_from_id).APs
    else
      self.APs
    end
  end

  class << self
    def validate_then_recreate(installations_list)
      puts 'Seeding installations...'
      puts '...validating'
      installations = []
      installations_list.each do |installation_raw|
        installation = Installation.new(
          name: installation_raw['name'],
          s3ic_id: installation_raw['s3ic_id'],
          region: installation_raw['region'],
          department: installation_raw['department'],
          zipcode: installation_raw['code_postal'],
          city: installation_raw['city'],
          last_inspection: installation_raw['last_inspection']&.to_date,
          regime: installation_raw['regime'],
          seveso: installation_raw['seveso'],
          state: installation_raw['active']
        )
        unless installation.validate
          raise "error validations #{installation.inspect} #{installation.errors.full_messages}"
        end

        installations << installation
      end

      recreate(installations)
    end

    private

    def recreate(installations)
      puts '...destroying'
      Installation.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Installation.table_name)
      puts '...creating'
      installations.each(&:save)
      puts "...done. Inserted #{Installation.count}/#{installations.length} installations."
    end
  end
end
