# frozen_string_literal: true

class Arrete < ApplicationRecord
  has_many :arretes_unique_classements, dependent: :delete_all
  has_many :unique_classements, through: :arretes_unique_classements
  has_many :enriched_arretes, dependent: :destroy

  validates :data, :summary, :short_title, :title, :cid, :aida_url, :legifrance_url, presence: true
  validates :title, length: { minimum: 10 }
  validates :short_title, format: { with: /\AArrêté du .* [0-9]{4}\z/,
                                    message: 'has wrong format.' }

  validates :unique_version, inclusion: { in: [true, false] }
  validates :cid, format: { with: /\A(JORF|LEGI)TEXT[0-9]{12}.*\z/ }
  validates :installation_date_criterion_left,
            format: { with: /\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/ },
            unless: lambda {
                      installation_date_criterion_left.blank?
                    }
  validates :installation_date_criterion_right,
            format: { with: /\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/ },
            unless: lambda {
                      installation_date_criterion_right.blank?
                    }
  validates :aida_url,
            format: { with: %r{\Ahttps://aida\.ineris\.fr/consultation_document/[0-9]{3,}\z} }

  validates :legifrance_url,
            format: { with: %r{\Ahttps://www\.legifrance\.gouv\.fr/loda/id/.*\z} }

  def data
    JSON.parse(super.to_json, object_class: OpenStruct)
  end

  class << self
    def validate_then_recreate(arretes_list)
      puts 'Seeding arretes...'
      puts '...validating'
      arretes = []
      arretes_list.each do |am|
        arrete = Arrete.new(
          data: am,
          cid: am['id'],
          short_title: am['short_title'],
          title: am.dig('title', 'text'),
          unique_version: am['unique_version'],
          installation_date_criterion_left: am.dig('installation_date_criterion', 'left_date'),
          installation_date_criterion_right: am.dig('installation_date_criterion', 'right_date'),
          aida_url: am['aida_url'],
          legifrance_url: am['legifrance_url'],
          summary: am['summary']
        )
        raise "error validations #{arrete.cid} #{arrete.errors.full_messages}" unless arrete.validate

        arretes << arrete
      end
      recreate(arretes)
    end

    private

    def recreate(arretes)
      puts '...destroying'
      Arrete.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Arrete.table_name)

      puts '...creating'
      arretes.each do |arrete|
        arrete.save

        arrete.data.classements_with_alineas.each do |arrete_classement|
          classements = UniqueClassement.where(rubrique: arrete_classement.rubrique, regime: arrete_classement.regime)
          classements.each do |classement|
            ArretesUniqueClassement.create(arrete_id: arrete.id, unique_classement_id: classement.id)
          end
        end
      end
      puts "...done. Inserted #{arretes.length} arretes."
    end
  end
end
