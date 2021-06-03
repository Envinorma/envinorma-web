# frozen_string_literal: true

class Arrete < ApplicationRecord
  validates :data, :title, :cid, :aida_url, :legifrance_url, :date_of_signature, :version_descriptor, presence: true
  validates :title, length: { minimum: 10 }

  validates :default_version, inclusion: { in: [true, false] }
  validates :cid, format: { with: /\A(JORF|LEGI)TEXT[0-9]{12}.*\z/ }

  validates :aida_url,
            format: { with: %r{\Ahttps://aida\.ineris\.fr/consultation_document/[0-9]{3,}\z} }

  validates :legifrance_url,
            format: { with: %r{\Ahttps://www\.legifrance\.gouv\.fr/loda/id/.*\z} }

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def classements_with_alineas
    JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def version_descriptor
    JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def short_title
    "AM - #{date_of_signature.strftime('%d/%m/%y')}"
  end

  def rank_score
    [applicable_rank_score, regime_rank_score]
  end

  def applicable_rank_score
    version_descriptor.applicable ? 0 : 1
  end

  def regime_rank_score
    raise 'Expecting at least one classement' if classements_with_alineas.length.zero?

    unique_regime = classements_with_alineas[0].regime
    case unique_regime
    when 'A'
      0
    when 'E'
      1
    when 'D'
      2
    else
      3
    end
  end

  class << self
    def validate_then_recreate(arretes_files)
      puts 'Seeding arretes...'
      arretes = []
      arretes_files.each do |json_file|
        am = JSON.parse(File.read(json_file))
        arrete = new_arrete(am)
        arretes << arrete
      end
      puts "Found #{arretes_files.length} arretes."
      recreate(arretes)
      puts "Inserted #{Arrete.count} arretes in total."
    end

    private

    def recreate(arretes)
      puts '...destroying'
      Arrete.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Arrete.table_name)

      puts '...creating'
      arretes.each(&:save)
      puts "...done. Inserted #{Arrete.count}/#{arretes.length} arretes."
    end

    def new_arrete(arrete_json)
      autorisation_date_known = arrete_json.dig('version_descriptor', 'aed_date', 'known_value')
      date_de_mise_en_service_known = arrete_json.dig('version_descriptor', 'date_de_mise_en_service', 'known_value')
      arrete = Arrete.new(
        data: arrete_json,
        cid: arrete_json['id'],
        date_of_signature: arrete_json['date_of_signature'].to_date,
        title: arrete_json.dig('title', 'text'),
        classements_with_alineas: arrete_json['classements_with_alineas'],
        aida_url: arrete_json['aida_url'],
        legifrance_url: arrete_json['legifrance_url'],
        default_version: autorisation_date_known != true && date_de_mise_en_service_known != true,
        version_descriptor: arrete_json['version_descriptor']
      )
      raise "error validations #{arrete.cid} #{arrete.errors.full_messages}" unless arrete.validate

      arrete
    end
  end
end
