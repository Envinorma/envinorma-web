# frozen_string_literal: true

module FilterAMs
  extend ActiveSupport::Concern

  def compute_applicable_ams_list(classements)
    classements_by_am_cid = get_ams_cid_from(classements)
    ams = deduce_list_of_ams(classements_by_am_cid)
    sort_ams(ams)
  end

  private

  def get_ams_cid_from(classements)
    all_ams = AM.where(default_version: true).pluck(:cid, :classements_with_alineas)
    result = {}
    classements.each do |classement|
      all_ams.each do |cid, am_classements|
        am_classements.each do |am_classement|
          am_rubrique = am_classement['rubrique']
          am_regime = am_classement['regime']
          next unless am_rubrique == classement.rubrique && am_regime == classement.regime

          result[cid] = [] unless result.key?(cid)
          result[cid].append(classement)
        end
      end
    end
    result
  end

  def deduce_list_of_ams(classements_by_am_cid)
    ams = []
    classements_by_am_cid.each do |cid, classements|
      ams << select_am_version(cid, classements)
    end
    ams
  end

  def select_am_version(cid, classements)
    # if multiple classements apply for one am we cannot rely on date so we pick the generic version
    return AM.find_by(cid: cid, default_version: true) if classements.length > 1

    classement = classements[0]

    version_descriptors = AM.where(cid: cid).pluck(:id, :version_descriptor)
    matches = []
    version_descriptors.each do |id, version_descriptor|
      matches << id if match(version_descriptor, classement)
    end
    raise "Expecting exactly one AM version to match, got #{matches.length} match(es)" if matches.length != 1

    AM.find(matches[0])
  end

  def match(version_descriptor, classement)
    match_autorisation = date_match(version_descriptor['aed_date'], classement.date_autorisation)
    match_mise_en_service = date_match(version_descriptor['date_de_mise_en_service'], classement.date_mise_en_service)
    match_autorisation && match_mise_en_service
  end

  def date_match(date_descriptor, classement_date)
    # if the date is not used for parametrization its a match
    return true if !date_descriptor['is_used_in_parametrization'] # rubocop:disable Style/NegatedIf

    # if date is used for parametrization we check if classement_date is present
    # if not we want a match with the AM version where "unknown_classement_date_version" is true
    # (and return false if "unknown_classement_date_version" is false)
    return date_descriptor['unknown_classement_date_version'] if classement_date.nil?

    # if classement_date is present we want to exclude AM version where "unknown_classement_date_version" is true
    return false if date_descriptor['unknown_classement_date_version']

    date_in_range(classement_date, date_descriptor['left_value'], date_descriptor['right_value'])
  end

  def date_in_range(candidate, left_date, right_date)
    left_value = timestamp(left_date) || -Float::INFINITY
    right_value = timestamp(right_date) || Float::INFINITY
    candidate_value = timestamp(candidate)
    left_value <= candidate_value && candidate_value < right_value
  end

  def timestamp(date)
    date&.to_datetime&.to_i
  end

  def sort_ams(ams)
    ams.sort_by(&:rank_score)
  end
end