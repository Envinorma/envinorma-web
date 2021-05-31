# frozen_string_literal: true

module FilterArretes
  extend ActiveSupport::Concern

  def get_arrete_cid_to_classements(classements)
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

  def timestamp(date)
    return unless date

    date.to_datetime.to_i
  end

  def date_in_range(candidate, left_date, right_date)
    left_value = timestamp(left_date) || -Float::INFINITY
    right_value = timestamp(right_date) || Float::INFINITY
    candidate_value = candidate.to_datetime.to_i
    left_value <= candidate_value && candidate_value <= right_value
  end

  def date_match(date_parameter_descriptor, classement_date)
    return true unless date_parameter_descriptor['is_used']

    if classement_date.nil?
      return false if date_parameter_descriptor['known_value'] == true

      return true
    end
    return false unless date_parameter_descriptor['known_value'] == true

    date_in_range(classement_date, date_parameter_descriptor['left_value'], date_parameter_descriptor['right_value'])
  end

  def match(version_descriptor, classement)
    match_autorisation = date_match(version_descriptor['aed_date'], classement.date_autorisation)
    match_mise_en_service = date_match(version_descriptor['installation_date'], classement.date_mise_en_service)
    match_autorisation && match_mise_en_service
  end

  def select_correct_version(cid, classement)
    version_descriptors = Arrete.where(cid: cid).pluck(:id, :version_descriptor)
    matches = []
    version_descriptors.each do |id, version_descriptor|
      matches << id if match(version_descriptor, classement)
    end
    raise "Expecting exactly one AM version to match, got #{matches.length} match(es)" if matches.length != 1

    Arrete.find(matches[0])
  end

  def fetch_arrete_version(cid, classements)
    if classements.length == 1
      select_correct_version(cid, classements[0])
    else
      Arrete.find_by(cid: cid, default_version: true)
    end
  end

  def deduce_list_of_arretes(am_cid_to_classements)
    arretes = []
    am_cid_to_classements.each do |cid, classements|
      arretes << fetch_arrete_version(cid, classements)
    end
    arretes
  end

  def arrete_regime_rank_score(arrete)
    return 3 if arrete.classements_with_alineas.length.zero?

    first_regime = arrete.classements_with_alineas[0].regime
    case first_regime
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

  def arrete_rank_score(arrete)
    [arrete.version_descriptor.applicable ? 0 : 1, arrete_regime_rank_score(arrete)]
  end

  def sort_arretes(arretes)
    arretes.sort_by { |arrete| arrete_rank_score(arrete) }
  end

  def compute_applicable_arretes_list(classements)
    am_cid_to_classements = get_arrete_cid_to_classements(classements)
    arretes = deduce_list_of_arretes(am_cid_to_classements)
    sort_arretes(arretes)
  end
end
