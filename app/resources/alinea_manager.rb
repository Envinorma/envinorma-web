# frozen_string_literal: true

ActiveRecord::Base.logger.level = 1

class AlineaManager
  include TopicHelper

  def self.recreate
    Rails.logger.info 'Recreating alinea store...'
    AlineaStore.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(AlineaStore.table_name)
    AM.all.each_with_index do |am, index|
      Rails.logger.info "Recreated alinea store for am #{index}/#{AM.count}" if (index % 10).zero?
      create_from_am(am)
    end
    Rails.logger.info '...done.'
  end

  def self.create_from_am(arrete_ministeriel)
    hashes = arrete_ministeriel.data.sections.map.with_index do |section, index|
      create_hashes_from_am_section(section, index.to_s, arrete_ministeriel.id, nil)
    end.flatten
    hashes.each { |hash| AlineaStore.new(hash).validate! }
    AlineaStore.insert_all(hashes) # rubocop:disable Rails/SkipsModelValidations
  end

  def self.create_hashes_from_am_section(section, section_rank, am_id, ascendant_topic)
    topic = ascendant_topic || section.annotations.topic
    section_hash = {
      am_id: am_id,
      section_id: section.id,
      section_name: section.reference.name,
      section_reference: section.reference.nb,
      section_rank: section_rank,
      topic: topic || TopicHelper::AUCUN
    }
    section.outer_alineas.map.with_index do |alinea, index_in_section|
      create_from_am_alinea(alinea, index_in_section, section_hash)
    end.flatten + section.sections.map.with_index do |subsection, subsection_index|
      create_hashes_from_am_section(subsection, "#{section_rank}.#{subsection_index}", am_id, topic)
    end.flatten
  end

  def self.create_from_am_alinea(alinea, index_in_section, section_hash)
    section_hash.merge(
      index_in_section: index_in_section,
      content: extract_prescription_content(alinea),
      is_table: alinea.text.blank? && alinea.table.present?
    )
  end

  def self.extract_prescription_content(alinea)
    return alinea.text if alinea.text.present?

    return open_struct_to_hash(alinea.table).to_json if alinea.table.present?

    ''
  end

  def self.open_struct_to_hash(object, hash = {})
    object.each_pair do |key, value|
      hash[key] = case value
                  when OpenStruct then open_struct_to_hash(value)
                  when Array then value.map { |v| open_struct_to_hash(v) }
                  else value
                  end
    end
    hash
  end
end
