# frozen_string_literal: true

module TopicHelper
  TOPICS = {
    'DISPOSITIONS_GENERALES' => 'Dispositions générales',
    'IMPLANTATION_AMENAGEMENT' => 'Implantation - aménagement',
    'EXPLOITATION' => 'Exploitation',
    'RISQUES' => 'Risques',
    'EAU' => 'Eau',
    'AIR_ODEURS' => 'Air - odeurs',
    'DECHETS' => 'Déchets',
    'BRUIT_VIBRATIONS' => 'Bruit - vibrations',
    'FIN_EXPLOITATION' => 'Fin d\'exploitation',
    '' => 'Aucun thème'
  }.freeze

  def section_topics(section, ascendant_topic = nil)
    # recursively computes the topics Hash of a section and all its descendant
    # NB :
    # - if section.annotations.topic is defined, then all descendant sections have this topic
    # - section topics list is the union of the topics of all its children sections
    ascendant_topic ||= section.annotations.topic
    result = {}
    descendant_topics = ascendant_topic.nil? ? [] : [ascendant_topic]
    section.sections.each do |subsection|
      subsection_topics = section_topics(subsection, ascendant_topic)
      result.update(subsection_topics)
      descendant_topics.concat(subsection_topics[subsection.id])
    end
    result[section.id] = descendant_topics.uniq
    result
  end
end
