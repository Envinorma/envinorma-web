# frozen_string_literal: true

class Arrete < ApplicationRecord
  has_many :arretes_unique_classements, dependent: :delete_all
  has_many :unique_classements, through: :arretes_unique_classements

  validates :data, :title, :cid, :aida_url, :legifrance_url, :date_of_signature, presence: true
  validates :title, length: { minimum: 10 }

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

  def classements_with_alineas
    JSON.parse(super.to_json, object_class: OpenStruct)
  end

  def enriched?
    !enriched_from_id.nil?
  end

  def short_title
    "AM - #{date_of_signature.strftime('%d/%m/%y')}"
  end

  class << self
    def validate_then_recreate(arretes_list, enriched_arretes_files)
      puts 'Seeding arretes...'
      puts '...validating'
      arretes = []
      arretes_list.each do |am|
        arretes << new_arrete(am, nil)
      end
      recreate(arretes)

      create_enriched_arretes(enriched_arretes_files)
    end

    private

    def recreate(arretes)
      puts '...destroying'
      Arrete.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Arrete.table_name)

      puts '...creating'
      arretes.each do |arrete|
        arrete.save

        arrete.classements_with_alineas.each do |arrete_classement|
          classements = UniqueClassement.where(rubrique: arrete_classement.rubrique, regime: arrete_classement.regime)
          classements.each do |classement|
            ArretesUniqueClassement.create(arrete_id: arrete.id, unique_classement_id: classement.id)
          end
        end
      end
      puts "...done. Inserted #{Arrete.count}/#{arretes.length} arretes."
    end

    def new_arrete(arrete_json, cid_to_arrete_id)
      arrete = Arrete.new(
        data: arrete_json,
        cid: arrete_json['id'],
        date_of_signature: arrete_json['date_of_signature'].to_date,
        title: arrete_json.dig('title', 'text'),
        classements_with_alineas: arrete_json['classements_with_alineas'],
        unique_version: arrete_json['unique_version'],
        installation_date_criterion_left: arrete_json.dig('installation_date_criterion', 'left_date'),
        installation_date_criterion_right: arrete_json.dig('installation_date_criterion', 'right_date'),
        aida_url: arrete_json['aida_url'],
        legifrance_url: arrete_json['legifrance_url'],
        enriched_from_id: cid_to_arrete_id.nil? ? nil : cid_to_arrete_id.fetch(arrete_json['id'])
      )
      raise "error validations #{arrete.cid} #{arrete.errors.full_messages}" unless arrete.validate

      arrete
    end

    def create_enriched_arretes(enriched_arretes_files)
      puts 'Seeding enriched arretes...'
      cid_to_arrete_id = {}
      Arrete.all.each do |arrete|
        cid_to_arrete_id[arrete.cid] = arrete.id
      end
      arretes = []
      enriched_arretes_files.each do |json_file|
        am = JSON.parse(File.read(json_file))
        arrete = new_arrete(am, cid_to_arrete_id)
        arretes << arrete
      end
      puts "Found #{enriched_arretes_files.length} enriched arretes."
      arretes.each(&:save)
      puts "Inserted #{Arrete.count} arretes in total."
    end
  end
end
