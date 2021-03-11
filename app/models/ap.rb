# frozen_string_literal: true

class AP < ApplicationRecord
  belongs_to :installation

  validates :url, :installation_id, presence: true
  validates :url, length: { is: 116 }
  validates :installation_s3ic_id, format: { with: /\A([0-9]{4}\.[0-9]{5})\z/,
                                             message: 'check s3ic_id format' }

  def self.recreate!(aps_list)
    AP.destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!(AP.table_name)

    aps_list.each do |ap|
      ap = AP.create(
        installation_s3ic_id: ap['installation_s3ic_id'],
        description: ap['description'],
        date: ap['date'],
        url: ap['url'],
        installation_id: Installation.find_by(s3ic_id: ap['installation_s3ic_id'])&.id
      )

      puts "AP not created for installation #{ap['installation_s3ic_id']}" unless ap.save
    end

    puts 'Arretes prefectoraux are seeded'
  end
end
