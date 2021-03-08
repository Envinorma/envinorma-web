# frozen_string_literal: true

class EnrichedArrete < ApplicationRecord
  belongs_to :arrete

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
