# frozen_string_literal: true

class AP < ApplicationRecord
  belongs_to :installation

  validates :georisques_id, :installation_id, :installation_s3ic_id, presence: true
  validates :georisques_id, length: { is: 36 }
  validates :georisques_id, format: { with: %r{\A([A-Z]{1}/[a-f0-9]{1}/[a-f0-9]{32})\z},
                                      message: 'check georisques_id format' }

  validates :installation_s3ic_id, format: { with: /\A([0-9]{4}\.[0-9]{5})\z/,
                                             message: 'check s3ic_id format' }

  def title
    "#{description} - #{date.strftime('%d/%m/%y')}"
  end

  def short_title
    "AP - #{date.strftime('%d/%m/%y')}"
  end

  class << self
    def validate_then_recreate(aps_list)
      puts 'Seeding AP...'
      puts '...validating'
      aps = []
      aps_list.each do |ap|
        installation_id = Installation.find_by(s3ic_id: ap['installation_s3ic_id'])&.id
        next unless installation_id

        ap = AP.new(
          installation_s3ic_id: ap['installation_s3ic_id'],
          description: ap['description'],
          date: ap['date'],
          georisques_id: ap['georisques_id'],
          installation_id: installation_id
        )
        raise "error validations #{ap.inspect} #{ap.errors.full_messages}" unless ap.validate

        aps << ap
      end
      recreate(aps)
    end

    private

    def recreate(aps)
      puts '...destroying'
      AP.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(AP.table_name)
      puts '...creating'
      aps.each(&:save)
      puts "...done. Inserted #{AP.count}/#{aps.length} AP."
    end
  end
end
