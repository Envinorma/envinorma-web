# frozen_string_literal: true

class Section < ApplicationRecord
  belongs_to :arrete
  has_many :alineas, -> { order(:rank) }, dependent: :destroy

  validates :rank, :level, :arrete_id, presence: true

  class << self
    def validate_then_recreate(sections_list)
      puts 'Seeding sections...'
      puts '...validating'
      sections = []
      sections_list.each do |section_raw|
        section = Section.new(
          id: section_raw['id'],
          rank: section_raw['rank'],
          title: section_raw['title'],
          level: section_raw['level'],
          active: section_raw['active'] == 'True',
          modified: section_raw['modified'] == 'True',
          warnings: section_raw['warnings'],
          reference_str: section_raw['reference_str'],
          previous_version: section_raw['previous_version'],
          arrete_id: section_raw['arrete_id']
        )
        raise "error validations #{section.id} #{section.errors.full_messages}" unless section.validate

        sections << section
      end
      recreate(sections)
    end

    private

    def recreate(sections)
      puts '...destroying'
      Section.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Section.table_name)

      puts '...creating'
      sections.each(&:save)
      puts "...done. Inserted #{Section.count}/#{sections.length} sections."
    end
  end
end
