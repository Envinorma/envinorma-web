# frozen_string_literal: true

class Alinea < ApplicationRecord
  belongs_to :section

  validates :rank, :section_id, presence: true

  def table
    JSON.parse(super.to_json, object_class: OpenStruct)
  end

  class << self
    def validate_then_recreate(alineas_list)
      puts 'Seeding alineas...'
      puts '...validating'
      alineas = []
      alineas_list.each do |alinea_raw|
        alinea = Alinea.new(
          id: alinea_raw['id'],
          rank: alinea_raw['rank'],
          active: alinea_raw['active'] == 'True',
          section_id: alinea_raw['section_id'],
          text: alinea_raw['text'],
          table: alinea_raw['table'].nil? ? nil : JSON.parse(alinea_raw['table'])
        )
        raise "error validations #{alinea.id} #{alinea.errors.full_messages}" unless alinea.validate

        alineas << alinea
      end
      recreate(alineas)
    end

    private

    def recreate(alineas)
      puts '...destroying'
      Alinea.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Alinea.table_name)

      puts '...creating'
      alineas.each(&:save)
      puts "...done. Inserted #{Alinea.count}/#{alineas.length} alineas."
    end
  end
end
