# frozen_string_literal: true

module PrescriptionsGroupingHelper
  def sort_and_group(prescriptions, by_topic)
    topic_groups = by_topic ? group_by_topics(prescriptions) : { nil => prescriptions }
    topic_groups.transform_values { |topic_prescriptions| sort_and_group_by_text(topic_prescriptions) }
  end

  def group_by_topics(prescriptions)
    prescriptions.sort_by { |presc| topic_score_rank(presc.topic) }.group_by(&:topic)
  end

  def topic_score_rank(topic)
    # Topics are always sorted alphabetically except for 
    # topic 'AUCUN' which is always the last topic
    topic == 'AUCUN' ? [1, 'AUCUN'] : [0, topic]
  end

  def sort_and_group_by_text(prescriptions)
    result = {}
    prescriptions.sort_by { |p| [p.type, p.created_at] }.group_by(&:text_reference).each do |text_reference, group|
      result[text_reference] = group.sort_by(&:rank_array).group_by(&:reference)
    end
    result
  end
end
