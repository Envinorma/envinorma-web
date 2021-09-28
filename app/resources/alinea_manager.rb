# frozen_string_literal: true

ActiveRecord::Base.logger.level = 1

class AlineaManager
  include TopicHelper

  def self.recreate
    Rails.logger.info 'Recreating alinea store...'
    AlineaStore.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(AlineaStore.table_name)
    AM.pluck(:id, :data).each_with_index do |am, index|
      # We avoid using OpenStruct to avoid memory leak
      am_id, data = am
      Rails.logger.info "Recreated alinea store for am #{index}/#{AM.count}" if (index % 10).zero?
      GC.start if index % 10 == 9 # Force garbage collection every 10 batches for RAM limitations
      create_from_am(am_id, data)
    end
    Rails.logger.info '...done.'
  end

  def self.create_from_am(am_id, am_data)
    hashes = am_data['sections'].map.with_index do |section, index|
      create_hashes_from_am_section(section, index.to_s, am_id, nil)
    end.flatten
    hashes.each { |hash| AlineaStore.new(hash).validate! }
    hashes = hashes[0..20] if ENV['HEROKU_APP_NAME'] == 'envinorma-staging-1'
    AlineaStore.insert_all(hashes) # rubocop:disable Rails/SkipsModelValidations
  end

  def self.create_hashes_from_am_section(section, section_rank, am_id, ascendant_topic)
    topic = ascendant_topic || section['annotations']['topic']
    section_hash = {
      am_id: am_id,
      section_id: section['id'],
      section_name: section['reference']['name'],
      section_reference: section['reference']['nb'],
      section_rank: section_rank,
      topic: topic || TopicHelper::AUCUN
    }
    section['outer_alineas'].map.with_index do |alinea, index_in_section|
      create_from_am_alinea(alinea, index_in_section, section_hash)
    end.flatten + section['sections'].map.with_index do |subsection, subsection_index|
      create_hashes_from_am_section(subsection, "#{section_rank}.#{subsection_index}", am_id, topic)
    end.flatten
  end

  def self.create_from_am_alinea(alinea, index_in_section, section_hash)
    section_hash.merge(
      index_in_section: index_in_section,
      content: extract_prescription_content(alinea),
      is_table: (alinea['text'].blank? && alinea['table'].present?) || false
    )
  end

  def self.extract_prescription_content(alinea)
    return alinea['text'] if alinea.fetch('text', nil).present?

    return alinea['table'].to_json if alinea.fetch('table', nil).present?

    ''
  end
end
