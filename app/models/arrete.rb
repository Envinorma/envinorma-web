# frozen_string_literal: true

class Arrete < ApplicationRecord
  include ApplicationHelper

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
    REGIMES[unique_regime]
  end

  class << self
    def validate_then_recreate(arretes_files)
      puts 'Seeding arretes...'
      arretes = []
      arretes_files.each_with_index do |json_file, index|
        am = JSON.parse(File.read(json_file))
        arrete = new_arrete(am)
        arretes << arrete
        puts "#{index + 1} arretes initialized" if index % 10 == 9
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
      arrete = Arrete.new(
        data: arrete_json,
        cid: arrete_json['id'],
        date_of_signature: arrete_json['date_of_signature'].to_date,
        title: arrete_json.dig('title', 'text'),
        classements_with_alineas: arrete_json['classements_with_alineas'],
        aida_url: arrete_json['aida_url'],
        legifrance_url: arrete_json['legifrance_url'],
        default_version: default_version?(arrete_json['version_descriptor']),
        version_descriptor: arrete_json['version_descriptor']
      )
      raise "error validations #{arrete.cid} #{arrete.errors.full_messages}" unless arrete.validate

      arrete
    end

    def default_version?(version_descriptor)
      default1 = default_version_for_date?(version_descriptor['aed_date'])
      default2 = default_version_for_date?(version_descriptor['date_de_mise_en_service'])
      default1 && default2
    end

    def default_version_for_date?(date_descriptor)
      raise 'Expecting non nil date_descriptor' if date_descriptor.nil?

      %w[unknown_classement_date_version is_used_in_parametrization].each do |key|
        raise "Expecting key #{key} in date_descriptor" unless date_descriptor.key?(key)
      end

      return true if date_descriptor['is_used_in_parametrization'] == false

      date_descriptor['unknown_classement_date_version'] == true
    end
  end
end
