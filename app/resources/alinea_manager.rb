# frozen_string_literal: true

class AlineaManager
  include OpenStructHelper

  def self.recreate
    AlineaStore.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(AlineaStore.table_name)
    AM.all.each do |am|
      create_from_am(am)
    end
  end

  def self.create_from_am(arrete_ministeriel)
    arrete_ministeriel.sections.each_with_index do |section, index|
      create_hashes_from_am_section(section, index.to_s, arrete_ministeriel.id)
    end
  end

  def self.create_hashes_from_am_section(section, section_rank, am_id)
    section_hash = {
      am_id: am_id,
      section_id: section.id,
      section_name: section.reference.name,
      section_reference: section.reference.nb,
      section_rank: section_rank,
      topic: section.annotations.topic
    }
    section.outer_alineas.each_with_index do |alinea, index_in_section|
      create_from_am_alinea(alinea, index_in_section, section_hash)
    end
    section.sections.each_with_index do |subsection, subsection_index|
      create_hashes_from_am_section(subsection, "#{section_rank}.#{subsection_index}", am_id)
    end
  end

  def self.create_from_am_alinea(alinea, index_in_section, section_hash)
    hash = section_hash.merge(
      index_in_section: index_in_section,
      content: extract_prescription_content(extract_content),
      is_table: alinea.text.blank? && alinea.table.present?
    )
    AlineaStore.create!(hash)
  end

  def self.create_alinea_content(alinea)
    return alinea.text if alinea.text.present?

    return create_table(alinea.table) if alinea.table.present?

    ''
  end
end
