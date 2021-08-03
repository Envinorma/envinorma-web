# frozen_string_literal: true

class AM < ApplicationRecord
  include ApplicationHelper
  include RegimeHelper
  include TopicHelper

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

  def topics_by_section
    # Hash which associates each section id to the list of topics of its descendant.
    topics = {}
    data.sections.each do |section|
      topics.update(section_topics(section))
    end
    topics
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
    def validate_then_recreate(ams_files)
      Rails.logger.info('Seeding ams...')
      ams = []
      ams_files.each_with_index do |json_file, index|
        am = JSON.parse(File.read(json_file))
        am = new_am(am)
        ams << am
        Rails.logger.info("#{index + 1} ams initialized") if index % 10 == 9
      end
      Rails.logger.info("Found #{ams_files.length} ams.")
      recreate(ams)
      Rails.logger.info("Inserted #{AM.count} ams in total.")
    end

    private

    def recreate(ams)
      Rails.logger.info '...destroying'
      AM.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(AM.table_name)

      Rails.logger.info('...creating')
      ams.each(&:save)
      Rails.logger.info("...done. Inserted #{AM.count}/#{ams.length} ams.")
    end

    def new_am(am_json)
      am = AM.new(
        data: am_json,
        cid: am_json['id'],
        date_of_signature: am_json['date_of_signature'].to_date,
        title: am_json.dig('title', 'text'),
        classements_with_alineas: am_json['classements_with_alineas'],
        aida_url: am_json['aida_url'],
        legifrance_url: am_json['legifrance_url'],
        default_version: default_version?(am_json['version_descriptor']),
        version_descriptor: am_json['version_descriptor']
      )
      raise "error validations #{am.cid} #{am.errors.full_messages}" unless am.validate

      am
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
