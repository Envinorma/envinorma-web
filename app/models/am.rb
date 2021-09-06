# frozen_string_literal: true

class AM < ApplicationRecord
  include ApplicationHelper
  include TopicHelper

  validates :data, :title, :cid, :aida_url, :legifrance_url, :date_of_signature, presence: true
  validates :title, length: { minimum: 10 }

  validates :is_transverse, inclusion: { in: [true, false] }
  validates :cid, format: { with: /\A(JORF|LEGI)TEXT[0-9]{12}.*\z/ }

  validates :aida_url,
            format: { with: %r{\Ahttps://aida\.ineris\.fr/consultation_document/[0-9]{3,}\z} }

  validates :legifrance_url,
            format: { with: %r{\Ahttps://www\.legifrance\.gouv\.fr/loda/id/.*\z} }

  def classements_with_alineas
    # Lazy argument, loaded once needed (and only once)
    @classements_with_alineas ||= JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def applicability
    # Lazy argument, loaded once needed (and only once)
    @applicability ||= JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def short_title
    "AM - #{date_of_signature.strftime('%d/%m/%y')}"
  end

  def topics_by_section
    # Hash which associates each section id to the list of topics of its descendant.
    topics = {}
    data['sections'].each do |section|
      topics.update(section_topics(section))
    end
    topics
  end

  def to_hash
    {
      title: title,
      cid: cid,
      nickname: nickname,
      is_transverse: is_transverse,
      aida_url: aida_url,
      legifrance_url: legifrance_url,
      date_of_signature: date_of_signature,
      # for fields below, we want the initial value, not the parsed one
      data: self['data'],
      classements_with_alineas: self['classements_with_alineas'],
      applicability: self['applicability']
    }
  end

  class << self
    def from_hash(am_hash)
      am = AM.new(
        title: am_hash.dig('title', 'text'),
        cid: am_hash['id'],
        nickname: am_hash['nickname'],
        is_transverse: am_hash['is_transverse'],
        aida_url: am_hash['aida_url'],
        legifrance_url: am_hash['legifrance_url'],
        date_of_signature: am_hash['date_of_signature'].to_date,
        data: { 'sections' => am_hash['sections'] }, # only sections is used, parsing is faster this way
        classements_with_alineas: am_hash['classements_with_alineas'],
        applicability: am_hash['applicability']
      )
      raise "error validations #{am.cid} #{am.errors.full_messages}" unless am.validate

      am
    end

    def from_classements(classements, match_on_alineas)
      # Fetch all AM ids that match the classements and return
      # the map of AM ids to matching classements
      # match_on_alineas: if true, we match on rubrique-regime-alineas, otherwise on rubrique-regime
      all_ams = all.pluck(:id, :classements_with_alineas)
      result = {}
      classements.each do |classement|
        all_ams.each do |id, am_classements|
          am_classements.each do |am_classement|
            next unless classements_match?(classement, am_classement, match_on_alineas)

            result[id] = [] unless result.key?(id)
            result[id].append(classement)
          end
        end
      end
      result
    end

    def classements_match?(classement, am_classement, match_on_alineas)
      match_rubrique = am_classement['rubrique'] == classement.rubrique
      match_regime = am_classement['regime'] == classement.regime
      match_alinea = match_on_alineas ? alineas_match?(classement.alinea, am_classement['alineas']) : true
      match_rubrique && match_regime && match_alinea
    end

    def alineas_match?(classement_alinea, am_alineas)
      am_alineas.blank? ? true : am_alineas.include?(classement_alinea)
    end
  end
end
