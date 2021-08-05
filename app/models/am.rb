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
    # Lazy argument, loaded once needed (and only once)
    @data ||= JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def classements_with_alineas
    # Lazy argument, loaded once needed (and only once)
    @classements_with_alineas ||= JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def version_descriptor
    # Lazy argument, loaded once needed (and only once)
    @version_descriptor ||= JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def version_identifier
    # string which identifies the version of the AM by combining cid and version_descriptor
    aed_date_identifier = date_parameter_identifier(version_descriptor.aed_date)
    date_de_mise_en_service_identifier = date_parameter_identifier(version_descriptor.date_de_mise_en_service)
    "#{cid}-#{aed_date_identifier}-#{date_de_mise_en_service_identifier}"
  end

  def date_parameter_identifier(date_parameter)
    [date_parameter.is_used_in_parametrization, date_parameter.left_value,
     date_parameter.right_value, date_parameter.unknown_classement_date_version].join('-')
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

  def to_hash
    {
      title: title,
      cid: cid,
      aida_url: aida_url,
      legifrance_url: legifrance_url,
      date_of_signature: date_of_signature,
      version_descriptor: self['version_descriptor'], # we want the initial value, not the one from the wrapper
      data: self['data'], # identical to version_descriptor
      classements_with_alineas: self['classements_with_alineas'], # identical to version_descriptor
      default_version: default_version
    }
  end

  class << self
    def from_hash(am_hash)
      am = AM.new(
        title: am_hash.dig('title', 'text'),
        cid: am_hash['id'],
        aida_url: am_hash['aida_url'],
        legifrance_url: am_hash['legifrance_url'],
        date_of_signature: am_hash['date_of_signature'].to_date,
        version_descriptor: am_hash['version_descriptor'],
        data: am_hash,
        classements_with_alineas: am_hash['classements_with_alineas'],
        default_version: default_version?(am_hash['version_descriptor'])
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
