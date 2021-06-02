# frozen_string_literal: true

module FilterArretes
  extend ActiveSupport::Concern

  def compute_applicable_arretes_list(classements)
    classements_by_am_cid = get_arretes_cid_from(classements)
    arretes = deduce_list_of_arretes(classements_by_am_cid)
    sort_arretes(arretes)
  end

  private

  def get_arretes_cid_from(classements)
    all_arretes = Arrete.where(default_version: true).pluck(:cid, :classements_with_alineas)
    result = {}
    classements.each do |classement|
      all_arretes.each do |cid, arrete_classements|
        arrete_classements.each do |arrete_classement|
          arrete_rubrique = arrete_classement['rubrique']
          arrete_regime = arrete_classement['regime']
          next unless arrete_rubrique == classement.rubrique && arrete_regime == classement.regime

          result[cid] = [] unless result.key?(cid)
          result[cid].append(classement)
        end
      end
    end
    result
  end

  def deduce_list_of_arretes(classements_by_am_cid)
    arretes = []
    classements_by_am_cid.each do |cid, classements|
      arretes << select_arrete_version(cid, classements)
    end
    arretes
  end

  def select_arrete_version(cid, classements)
    # if multiple classements apply for one arrete we cannot rely on date so we pick the generic version
    return Arrete.find_by(cid: cid, default_version: true) if classements.length > 1

    classement = classements[0]

    version_descriptors = Arrete.where(cid: cid).pluck(:id, :version_descriptor)
    matches = []
    version_descriptors.each do |id, version_descriptor|
      matches << id if match(version_descriptor, classement)
    end
    raise "Expecting exactly one AM version to match, got #{matches.length} match(es)" if matches.length != 1

    Arrete.find(matches[0])
  end

  def match(version_descriptor, classement)
    match_autorisation = date_match(version_descriptor['aed_date'], classement.date_autorisation)
    match_mise_en_service = date_match(version_descriptor['installation_date'], classement.date_mise_en_service)
    match_autorisation && match_mise_en_service
  end

  def date_match(date_descriptor, classement_date)
    # if the date is not used for parametrization its a match
    return true if date_descriptor['is_not_used_in_parametrization']

    # if date is used for parametrization we check if classement_date is present
    # if not we want a match with the AM version where "unknown_classement_date_version" is true
    # (and return false if "unknown_classement_date_version" is false)
    return date_descriptor['unknown_classement_date_version'] if classement_date.nil?

    # if classement_date is present we want to exclude AM version where "unknown_classement_date_version" is true
    return false if date_descriptor['unknown_classement_date_version']

    date_in_range(classement_date, date_descriptor['left_value'], date_descriptor['right_value'])
  end

  def date_in_range(candidate, left_date, right_date)
    left_value = left_date&.to_timestamp || -Float::INFINITY
    right_value = right_date&.to_timestamp || Float::INFINITY
    candidate_value = candidate.to_timestamp
    left_value <= candidate_value && candidate_value <= right_value
  end

  def sort_arretes(arretes)
    arretes.sort_by(&:rank_score)
  end
end
