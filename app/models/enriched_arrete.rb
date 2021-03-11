# frozen_string_literal: true

class EnrichedArrete < ApplicationRecord
  belongs_to :arrete

  validates :title, length: { minimum: 10 }
  validates :unique_version, inclusion: { in: [true, false], message: 'must be true or false' }
  validates :short_title, format: { with: /\AArrêté du .* [0-9]{4}\z/,
                                    message: 'has wrong format.' }
  validates :installation_date_criterion_left,
            format: { with: /\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/ },
            unless: lambda {
                      installation_date_criterion_left.blank?
                    }
  validates :installation_date_criterion_right,
            format: { with: /\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/ },
            unless: lambda {
                      installation_date_criterion_right.blank?
                    }
  validates :aida_url,
            format: { with: %r{\Ahttps://aida\.ineris\.fr/consultation_document/[0-9]{3,}\z} },
            unless: lambda {
                      installation_date_criterion_right.blank?
                    }
  validates :legifrance_url,
            format: { with: %r{\Ahttps://www\.legifrance\.gouv\.fr/loda/id/.*\z} },
            unless: lambda {
                      installation_date_criterion_right.blank?
                    }
  validates :summary, presence: true

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def self.recreate!(enriched_arretes_files)
    EnrichedArrete.destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!(EnrichedArrete.table_name)

    enriched_arretes_files.each do |json_file|
      am = JSON.parse(File.read(json_file))
      EnrichedArrete.create(
        data: am,
        short_title: am['short_title'],
        title: am.dig('title', 'text'),
        unique_version: am['unique_version'],
        installation_date_criterion_left: am.dig('installation_date_criterion', 'left_date'),
        installation_date_criterion_right: am.dig('installation_date_criterion', 'right_date'),
        aida_url: am['aida_url'],
        legifrance_url: am['legifrance_url'],
        summary: am['summary'],
        arrete_id: Arrete.find_by(cid: am['id']).id
      )
    end

    puts 'Enriched arretes are created'
  end
end
